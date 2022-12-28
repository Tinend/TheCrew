# frozen_string_literal: true

# Öffentliche Information über das Spiel, i.e.:
# * Anzahl Spieler,
# * Wer fängt an.
# * Welche Spieler hat welche Aufträge.
# * Welche Karten sind gegangen.
class SpielInformation
  def initialize(anzahl_spieler)
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
end
