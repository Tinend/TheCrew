# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../karte'
require_relative '../leerer_reporter'
require_relative '../tee_reporter'
require_relative 'ai_input_ersteller'
require_relative 'spiel_informations_sicht_benutzender'
require_relative 'zufalls_entscheider'
require_relative 'q_learning_modell'
require_relative 'bewerter'
require_relative 'ai_aktions_raum'
require 'ruby-fann'

# Ein Entscheider, der auf einem AI Modell basiert.
# Er benutzt ab und zu seinen Basis Entscheider, ab und zu macht er selbst
# etwas.
class QLearningEntscheider < Entscheider
  def initialize(zufalls_generator:, zaehler_manager:)
    super

    @discount = 0.9
    @epsilon = 0.1
    @max_epsilon = 0.9
    @epsilon_increase_factor = 800.0
    @runs = 0
  end

  attr_reader :alter_ai_input, :spiel_informations_sicht

  def modell
    @modell ||= QLearningModell.instanz
  end

  include SpielInformationsSichtBenutzender

  def bewerter
    @bewerter ||= Bewerter.new
  end

  # Reporter, der dem Modell hilft, Verluste und Gewinne zu benutzen.
  class AiReporter < LeererReporter
    def initialize(entscheider)
      super()
      @entscheider = entscheider
    end

    def berichte_gewonnen
      @entscheider.modell.merke(nil, @entscheider.bewerter.bewerte_verloren(@entscheider.spiel_informations_sicht),
                                @entscheider.alter_ai_input, [])
    end

    def berichte_verloren
      @entscheider.modell.merke(nil, @entscheider.bewerter.bewerte_gewonnen(@entscheider.spiel_informations_sicht),
                                @entscheider.alter_ai_input, [])
    end
  end

  def reporter
    @reporter ||= TeeReporter.new([AiReporter.new(self), basis_entscheider.reporter].compact)
  end

  def kommuniziert?
    @zufalls_generator.rand(karten.length).zero?
  end

  def basis_entscheider
    @basis_entscheider ||= ZufallsEntscheider.new(zufalls_generator: @zufalls_generator,
                                                  zaehler_manager: @zaehler_manager)
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

  def waehle_basis_aktion(aktions_raum)
    aktions_raum.lasse_entscheider_waehlen(basis_entscheider)
  end

  def waehle_kommunikation(kommunizierbares)
    waehle_aktion(AiAktionsRaum.new(:kommunikation, kommunizierbares))
  end

  def waehl_auftrag(auftraege)
    waehle_aktion(AiAktionsRaum.new(:auftrag, auftraege))
  end

  def waehle_karte(stich, waehlbare_karten)
    waehle_aktion(AiAktionsRaum.new(:karte, waehlbare_karten, stich))
  end

  def waehle_aktion(aktions_raum)
    bewertung = bewerter.bewerte(@spiel_informations_sicht)
    ai_input = AiInputErsteller.ai_input(@spiel_informations_sicht, aktions_raum.art)
    modell.merke(ai_input, bewertung, @alter_ai_input, aktions_raum.ai_aktionen)
    epsilon_run_factor = [(@runs / @epsilon_increase_factor), (@max_epsilon - @epsilon)].min
    aktion = if @zufalls_generator.rand > (@epsilon + epsilon_run_factor)
               @zaehler_manager.erhoehe_zaehler(:basis_aktion)
               waehle_basis_aktion(aktions_raum)
             else
               @zaehler_manager.erhoehe_zaehler(:modell_aktion)
               waehle_modell_aktion(aktions_raum, ai_input)
             end
    @alter_ai_input = ai_input
    aktion
  end

  def waehle_modell_aktion(aktions_raum, ai_input)
    return aktions_raum.einzige.aktion if aktions_raum.length == 1

    start = Time.now
    puts '    Modell Aktion'
    beste_ai_aktion = aktions_raum.ai_aktionen.max_by do |ai_aktion|
      ai_input.setze_aktion(ai_aktion)
      modell_bewerte(ai_input)
    end
    puts "    #{Time.now - start} Sekunden"
    beste_ai_aktion.aktion
  end

  def modell_bewerte(ai_input)
    @zaehler_manager.erhoehe_zaehler(:modell_aufruf)
    modell.bewerte(ai_input)
  end
end
