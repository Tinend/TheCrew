# coding: utf-8
# frozen_string_literal: true

require 'karte'

# Gesamte Information über die Spiel Situation, i.e.:
# * Anzahl Spieler
# * Wer hat welche Karten.
# * Wer fängt an.
# * Welche Spieler hat welche Aufträge.
# * Welche Karten sind gegangen.
# * Wer was kommuniziert hat.
class SpielInformation
  def initialize(anzahl_spieler:)
    @anzahl_spieler = anzahl_spieler
    @stiche = []
    @auftraege = Array.new(anzahl_spieler) { [] }
    @kommunikationen = Array.new(anzahl_spieler) { nil }
    @karten = Array.new(anzahl_spieler) { [] }
    @kapitaen_index = nil
  end

  attr_reader :anzahl_spieler, :kapitaen_index, :stiche, :auftraege, :karten

  def auftrag_gewaehlt(spieler_index:, auftrag:)
    @auftraege[spieler_index].push(auftrag)
  end

  # Verteilt die gegebenen Karten an die Spieler.
  # `karten` ist ein Array indiziert mit dem Spieler index mit den Karten des jeweilgen Spielers.
  def verteil_karten(karten)
    @karten = karten
    @kapitaen_index = karten.find_index { |k| k.include?(Karte.max_trumpf) }
  end

  # Existiert ein Spieler, der keine Karten mehr hat?
  def existiert_blanker_spieler?
    @karten.any?(&:empty?)
  end

  # Indiziert mit dem `spieler_index`.
  def unerfuellte_auftraege
    @auftraege.map { |as| as.reject(&:erfuellt) }
  end

  def alle_auftraege_erfuellt?
    unerfuellte_auftraege.flatten.empty?
  end

  def kommuniziert(spieler_index:, kommunikation:)
    @kommunikationen[spieler_index] = kommunikation
  end

  def karte_gespielt(spieler_index:, karte:)
    @karten[spieler_index].delete(karte)
  end

  def stich_fertig(stich)
    @stiche.push(stich)
  end

  def fuer_spieler(spieler_index)
    SpielInformationsSicht.new(spiel_information: self, spieler_index: spieler_index)
  end

  # Information aus Sicht eines Spielenrs (i.e. Spieler Indices sind entsprechend umgerechnet).
  class SpielInformationsSicht
    def initialize(spiel_information:, spieler_index:)
      @spiel_information = spiel_information
      @spieler_index = spieler_index
    end

    def anzahl_spieler
      @spiel_information.anzahl_spieler
    end

    def kapitaen_index
      n = @spiel_information.anzahl_spieler
      (@spiel_information.kapitaen_index - @spieler_index + n) % n
    end

    def karten
      @spiel_information.karten[@spieler_index]
    end

    def auftraege
      @spiel_information.auftraege.rotate(@spieler_index)
    end

    def unerfuellte_auftraege
      @spiel_information.unerfuellte_auftraege.rotate(@spieler_index)
    end

    def kommunikationen
      @spiel_information.kommunikationen.rotate(@spieler_index)
    end

    def stiche
      @spiel_information.stiche
    end

    def eigene_auftraege
      auftraege.first
    end
  end
end
