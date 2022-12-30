# frozen_string_literal: true

require_relative 'karte'

# verwaltet einen Stich und Karten die drauf gelegt werden
class Stich
  # Eine Karte die von einem Spieler gespielt wurde.
  class GespielteKarte
    def initialize(spieler_index:, karte:)
      @spieler_index = spieler_index
      @karte = karte
    end

    attr_reader :karte, :spieler_index

    def farbe
      @karte.farbe
    end
  end

  def initialize
    @gespielte_karten = []
    @staerkste_gespielte_karte = nil
  end

  attr_reader :gespielte_karten, :staerkste_gespielte_karte

  def staerkste_karte
    @staerkste_gespielte_karte&.karte
  end

  def karten
    @gespielte_karten.map(&:karte)
  end

  def sieger_index
    @staerkste_gespielte_karte&.spieler_index
  end

  def farbe
    @gespielte_karten.first.farbe unless @gespielte_karten.empty?
  end

  def empty?
    @gespielte_karten.empty?
  end

  def length
    @gespielte_karten.length
  end

  # Gibt `true` zurück, wenn die Karte schlägt.
  def legen(karte:, spieler_index:)
    gespielte_karte = GespielteKarte.new(spieler_index: spieler_index, karte: karte)
    @gespielte_karten.push(gespielte_karte)
    schlaegt = @gespielte_karte.nil? || gespielte_karte.karte.schlaegt?(@staerkste_gespielte_karte.karte)
    @staerkste_gespielte_karte = gespielte_karte if schlaegt
    schlaegt
  end

  def to_s
    karten.join(' ')
  end
end
