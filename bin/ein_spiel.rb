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
require 'karte'

ANZAHL_SPIELER = 4

richter = Richter.new()
spiel_information = SpielInformation.new(anzahl_spieler: ANZAHL_SPIELER)
spieler = Array.new(ANZAHL_SPIELER) {|i|
  Spieler.new(entscheider: ZufallsEntscheider.new(), spiel_informations_sicht: spiel_information.fuer_spieler(i))
}
karten_verwalter = KartenVerwalter.new(karten: Karte.alle, spieler: spieler)
karten_verwalter.verteilen()
auftraege = Karte.alle.map {|karte| Auftrag.new(karte)}
auftrag_verwalter = AuftragVerwalter.new(auftraege: auftraege, spieler: spieler)
auftrag_verwalter.auftraege_ziehen(anzahl: 1, richter: richter)
auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
spiel = Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information)
until richter.gewonnen or richter.verloren
  spiel.runde()
end
if richter.verloren
  puts "Leider wurde das Spiel verloren"
elsif richter.gewonnen
  puts "Herzliche Gratulation!"
end
  
