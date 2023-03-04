require_relative '../entscheider'
require_relative '../karte'
require_relative '../leerer_reporter'
require_relative '../tee_reporter'
require_relative 'ai_input_ersteller'
require_relative 'spiel_informations_sicht_benutzender'
require_relative 'zufalls_entscheider'
require_relative 'q_learning_modell'
require_relative 'bewerter'
require 'ruby-fann'

class QLearningEntscheider < Entscheider
  def initialize(zufalls_generator:, zaehler_manager:)
    super

    @discount = 0.9
    @epsilon = 0.1
    @max_epsilon = 0.9
    @epsilon_increase_factor = 800.0
    @runs = 0
  end

  attr_reader :alter_input, :spiel_informations_sicht

  def modell
    @modell ||= QLearningModell.instanz
  end

  include SpielInformationsSichtBenutzender

  def bewerter
    @bewerter ||= Bewerter.new
  end

  def input_ersteller
    @input_ersteller ||= AiInputErsteller.new
  end

  class AiReporter < LeererReporter
    def initialize(entscheider)
      @entscheider = entscheider
    end

    def berichte_gewonnen
      @entscheider.modell.merke(nil, @entscheider.bewerter.bewerte_verloren(@entscheider.spiel_informations_sicht), @entscheider.alter_input)
    end

    def berichte_verloren
      @entscheider.modell.merke(nil, @entscheider.bewerter.bewerte_gewonnen(@entscheider.spiel_informations_sicht), @entscheider.alter_input)
    end
  end

  def reporter
    @reporter ||=
      begin
        reporter = TeeReporter.new([AiReporter.new(self), basis_entscheider.reporter].compact)
      end
  end

  def kommuniziert?
    @zufalls_generator.rand(karten.length).zero?
  end

  def basis_entscheider
    @basis_entscheider ||= ZufallsEntscheider.new(zufalls_generator: @zufalls_generator, zaehler_manager: @zaehler_manager)
  end

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    super
    basis_entscheider.sehe_spiel_informations_sicht(spiel_informations_sicht)
  end

  def stich_fertig
    basis_entscheider.stich_fertig
  end

  def vorbereitungs_phase
    basis_entscheider.vorbereitungs_phase
  end

  def waehle_basis_aktion(aktions_art, optionen)
    case aktions_art
    when :kommunikation
      basis_entscheider.waehle_kommunikation(optionen)
    when :auftrag
      basis_entscheider.waehl_auftrag(optionen)
    when :karte
      basis_entscheider.waehle_karte(@spiel_informations_sicht.aktiver_stich, optionen)
    end
  end

  def waehle_kommunikation(kommunizierbares)
    waehle_aktion(:kommunikation, kommunizierbares)
  end
  
  def waehl_auftrag(auftraege)
    waehle_aktion(:auftrag, auftraege)
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehle_aktion(:karte, waehlbare_karten)
  end

  def waehle_aktion(aktions_art, optionen)
    bewertung = bewerter.bewerte(@spiel_informations_sicht)
    input = input_ersteller.input(@spiel_informations_sicht, aktions_art)
    modell.merke(input, bewertung, @alter_input)
    epsilon_run_factor = (@runs/@epsilon_increase_factor) > (@max_epsilon-@epsilon) ? (@max_epsilon-@epsilon) : (@runs/@epsilon_increase_factor)
    aktion = if @zufalls_generator.rand > (@epsilon + epsilon_run_factor)
               @zaehler_manager.erhoehe_zaehler(:basis_aktion)
               waehle_basis_aktion(aktions_art, optionen)
             else
               @zaehler_manager.erhoehe_zaehler(:modell_aktion)
               waehle_modell_aktion(aktions_art, input, optionen)
             end
    @alter_input = input
    aktion
  end

  def waehle_modell_aktion(aktions_art, input, optionen)
    adaptierte_optionen = aktions_art == :kommunikation ? optionen + [nil] : optionen
    return adaptierte_optionen.first if adaptierte_optionen.length == 1
    start = Time.now
    puts "Model Aktion"
    option = adaptierte_optionen.max_by do |option|
      # Create neural network input vector for this action
      input_state_action = input.clone
      # Set a 1 in the action location of the input vector
      if option.nil?
        input_state_action[Karte.alle.length] = 1
      else
        karte = option.is_a?(Karte) ? option : option.karte
        input_state_action[AiInputErsteller.karten_index(karte)] = 1
      end

      modell_bewerte(input_state_action)
    end
    puts "#{Time.now - start} Sekunden"
    option
  end

  def modell_bewerte(input)
    @zaehler_manager.erhoehe_zaehler(:modell_aufruf)
    modell.bewerte(input)
  end
end
