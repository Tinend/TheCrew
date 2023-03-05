# frozen_string_literal: true

require_relative '../../kommunikation'
require_relative '../../auftrag'
require_relative '../../karte'
require_relative 'ai_input_ersteller'

# Stellt die möglichen Aktionen in einem Zug vor, i.e. eines der folgenden:
# * Alle möglichen ausspielbaren Karten.
# * Alle möglichen wählbaren Aufträge.
# * Alle möglichen Kommunikationen (inklusive "gar nicht").
class AiAktionsRaum
  ARTEN_KLASSEN = { kommunikation: Kommunikation, auftrag: Auftrag, karte: Karte }.freeze
  ARTEN = ARTEN_KLASSEN.keys.freeze

  # Stellt eine mögliche Aktion (siehe AiAktionsRaum) dar.
  class AiAktion
    def initialize(aktion, index)
      @aktion = aktion
      @index = index
    end

    attr_reader :aktion, :index
  end

  NICHT_KOMMUNIZIER_AKTION = AiAktion.new(nil, Karte.alle.length)

  def self.maximal_laenge
    Karte.alle.length + 1
  end

  def initialize(art, optionen, stich = nil)
    raise ArgumentError unless ARTEN.include?(art)
    raise TypeError unless optionen.all?(ARTEN_KLASSEN[art])
    raise ArgumentError if stich && art != :karte
    raise ArgumentError if !stich && art == :karte

    @art = art
    @optionen = optionen
    @stich = stich
  end

  attr_reader :art

  def length
    ai_aktionen.length
  end

  def einzige
    raise ArgumentError unless length == 1

    ai_aktionen.first
  end

  def lasse_entscheider_waehlen(entscheider)
    case @art
    when :kommunikation
      entscheider.waehle_kommunikation(@optionen)
    when :auftrag
      entscheider.waehl_auftrag(@optionen)
    when :karte
      entscheider.waehle_karte(@stich, @optionen)
    end
  end

  def ai_aktionen
    @ai_aktionen ||=
      begin
        ai_aktionen = @optionen.map do |option|
          karte = @art == :karte ? option : option.karte
          index = AiInputErsteller.karten_index(karte)
          AiAktion.new(option, index)
        end
        ai_aktionen.push(NICHT_KOMMUNIZIER_AKTION) if @art == :kommunikation
        ai_aktionen
      end
  end
end
