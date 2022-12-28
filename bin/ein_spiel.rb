#!/usr/bin/ruby

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'richter'
require 'spiel_information'
require 'entscheider/zufalls_entscheider'
require 'spieler'
require 'spiel'
require 'auftrag_verwalter'
require 'karten_verwalter'
require 'auftrag'

ANZAHL_SPIELER = 4

richter = Richter.new()
spiel_information = SpielInformation.new(4)
spieler = Array.new(ANZAHL_SPIELER) {|i|
  Spieler.new(entscheider: ZufallsEntscheider.new(), spiel_information: spiel_information.fuer_spieler(i))
}
spiel = Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information)
karten_verwalter = KartenVerwalter.new(karten: Karten.all, spieler: spieler)
karten_verwalter.verteilen()
auftraege = Karten.all.map {|karte| Auftrag.new(karte)}
auftrag_verwalter = AuftragVerwalter.new(auftraege: auftraege, spieler: spieler)
auftrag_verwalter.auftraege_ziehen(anzahl: 1, richter: richter)
auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
until richter.gewonnen or richter.verloren
  spiel.runde()
end
if richter.verloren
  puts "Leider wurde das Spiel verloren"
elsif richter.gewonnen
  puts "Herzliche Gratulation!"
end
  
