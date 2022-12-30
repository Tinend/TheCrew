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

  def auftraege_ziehen(anzahl:, zufalls_generator: Random.new)
    @auftraege.shuffle!(random: zufalls_generator)
    @ausgelegte_auftraege = @auftraege[0...anzahl]
    @ausgelegte_auftraege.each(&:aktivieren)
  end

  def auftraege_verteilen(spiel_information:)
    start = spiel_information.kapitaen_index
    @ausgelegte_auftraege.length.times do |i|
      wahl = @spieler[(start + i) % @spieler.length].waehl_auftrag(@ausgelegte_auftraege)
      spiel_information.auftrag_gewaehlt(auftrag: wahl, spieler_index: (start + i) % @spieler.length)
      @ausgelegte_auftraege.delete(wahl)
    end
  end
end
