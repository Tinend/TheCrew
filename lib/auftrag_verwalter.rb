# coding: utf-8
# frozen_string_literal: true

# zieht die Aufträge und lässt die Spieler davon auswählen
class AuftragVerwalter
  def initialize(auftraege:, spieler:)
    @auftraege = auftraege
    @ausgelegte_auftraege = []
    @spieler = spieler
  end

  attr_reader :ausgelegte_auftraege

  def auftraege_ziehen(anzahl:, richter:)
    @auftraege.shuffle!
    @ausgelegte_auftraege = @auftraege[0...anzahl]
    richter.auftraege_erhalten(@ausgelegte_auftraege)
  end

  def auftraege_verteilen(spiel_information:)
    start = @spieler.find_index(&:faengt_an?)
    @ausgelegte_auftraege.length.times do |i|
      wahl = @spieler[(start + i) % @spieler.length].waehl_auftrag(@auftraege)
      spiel_information.auftrag_gewaehlt(auftrag: wahl, spieler_index: (start + i) % @spieler.length)
      @ausgelegte_auftraege.delete(wahl)
    end
  end
end
