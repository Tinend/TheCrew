#!/usr/bin/ruby
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'richter'
require 'spiel_information'
require 'entscheider/zufalls_entscheider'
require 'entscheider/hase'
require 'entscheider/saeuger'
require 'spieler'
require 'spiel'
require 'auftrag_verwalter'
require 'karten_verwalter'
require 'auftrag'
require 'karte'

ANZAHL_SPIELER = 4
ANZAHL_AUFTRAEGE = 1
ANZAHL_SPIELE = 1000
ENTSCHEIDER = [ZufallsEntscheider, Hase, Saeuger]

zufalls_generator = Random.new()

ENTSCHEIDER.each do |entscheider|
  persoenlicher_zufalls_generator = zufalls_generator.dup
  punkte = 0
  ANZAHL_SPIELE.times do |i|
    richter = Richter.new
    spiel_information = SpielInformation.new(anzahl_spieler: ANZAHL_SPIELER)
    spieler = Array.new(ANZAHL_SPIELER) do |i|
      Spieler.new(entscheider: entscheider.new, spiel_informations_sicht: spiel_information.fuer_spieler(i))
    end
    karten_verwalter = KartenVerwalter.new(karten: Karte.alle.dup, spieler: spieler)
    karten_verwalter.verteilen(zufalls_generator: persoenlicher_zufalls_generator)
    auftraege = Karte.alle_normalen.map { |karte| Auftrag.new(karte) }
    auftrag_verwalter = AuftragVerwalter.new(auftraege: auftraege, spieler: spieler)
    auftrag_verwalter.auftraege_ziehen(anzahl: ANZAHL_AUFTRAEGE, richter: richter, zufalls_generator: persoenlicher_zufalls_generator)
    auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
    spiel = Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information, ausgeben: false)
    spiel.runde(ausgeben: false) until richter.gewonnen || richter.verloren
    if richter.gewonnen
      punkte += 1
    end
  end
  puts "#{entscheider} hat #{punkte} Punkte geholt."
end
