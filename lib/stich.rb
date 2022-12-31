# coding: utf-8
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

  # Ein Modul, was Hilfsmethoden beinhaltet, die sowohl für den Stich
  # als auch die StichSicht existieren.
  module StichArtig
    def staerkste_karte
      staerkste_gespielte_karte&.karte
    end

    def karten
      gespielte_karten.map(&:karte)
    end

    def sieger_index
      staerkste_gespielte_karte&.spieler_index
    end

    def farbe
      gespielte_karten.first.farbe unless gespielte_karten.empty?
    end

    def empty?
      gespielte_karten.empty?
    end

    def length
      gespielte_karten.length
    end
  end

  include StichArtig

  def initialize
    @gespielte_karten = []
    @staerkste_gespielte_karte = nil
  end

  attr_reader :gespielte_karten, :staerkste_gespielte_karte

  def fuer_spieler(spieler_index:, anzahl_spieler:)
    StichSicht.new(stich: self, spieler_index: spieler_index, anzahl_spieler: anzahl_spieler)
  end

  # Gibt `true` zurück, wenn die Karte schlägt.
  def legen(karte:, spieler_index:)
    gespielte_karte = GespielteKarte.new(spieler_index: spieler_index, karte: karte)
    @gespielte_karten.push(gespielte_karte)
    schlaegt = @staerkste_gespielte_karte.nil? || gespielte_karte.karte.schlaegt?(@staerkste_gespielte_karte.karte)
    @staerkste_gespielte_karte = gespielte_karte if schlaegt
    schlaegt
  end

  def to_s
    karten.join(' ')
  end

  # Stich aus Sicht eines bestimmten Spielers, i.e. die Indizes sind für ihn umgerechnet.
  class StichSicht
    include StichArtig

    def initialize(stich:, spieler_index:, anzahl_spieler:)
      @stich = stich
      @spieler_index = spieler_index
      @anzahl_spieler = anzahl_spieler
    end

    def wandle_gespielte_karte_um(gespielte_karte)
      n = @anzahl_spieler
      umgewandelter_spieler_index = (gespielte_karte.spieler_index - @spieler_index + n) % n
      GespielteKarte.new(karte: gespielte_karte.karte, spieler_index: umgewandelter_spieler_index)
    end

    def staerkste_gespielte_karte
      wandle_gespielte_karte_um(@stich.staerkste_gespielte_karte)
    end

    def gespielte_karten
      @stich.gespielte_karten.map { |k| wandle_gespielte_karte_um(k) }
    end
  end
end
