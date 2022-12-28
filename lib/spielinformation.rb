# frozen_string_literal: true

# Öffentliche Information über das Spiel, i.e.:
# * Anzahl Spieler,
# * Wer fängt an.
# * Welche Spieler hat welche Aufträge.
# * Welche Karten sind gegangen.
class SpielInformation
  def initialize(anzahl_spieler:)
    @anzahl_spieler = anzahl_spieler
    @stiche = []
    @auftraege = Array.new(anzahl_spieler) { [] }
  end

  attr_reader :anzahl_spieler, :kapitaen, :stiche, :auftraege

  def auftrag_gewaehlt(spieler_index:, auftrag:)
    @auftraege[spieler_index].push(auftrag)
  end

  def setze_kapitaen(spieler_index)
    @kapitaen = spieler_index
  end

  def stich_fertig(stich)
    @stiche.push(stich)
  end

  def fuer_spieler(spieler_index)
    SpielInformationsSicht.new(self, spieler_index)
  end

  class SpielInformationsSicht
    def initialize(spiel_information:, spieler_index:)
      @spiel_information = spiel_information
      @spieler_index = spieler_index
    end

    def anzahl_spieler
      @spiel_information.anzahl_spieler
    end

    def kapitaen
      (@spiel_information.kapitaen - @spieler_index + @spiel_information.anzahl_spieler) % @spiel_information.anzahl_spieler
    end

    def auftraege
      @spiel_information.auftraege.rotate(@spieler_index)
    end

    def stiche
      @spiel_information.stiche
    end
  end
end
