#!/usr/bin/ruby
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'richter'
require 'spiel_information'
require 'entscheider/zufalls_entscheider'
require 'entscheider/hase'
require 'entscheider/reinwerfer'
require 'spieler'
require 'spiel'
require 'auftrag_verwalter'
require 'karten_verwalter'
require 'auftrag'
require 'karte'

ANZAHL_SPIELER = 4
ANZAHL_AUFTRAEGE = 3

spiel_information = SpielInformation.new(anzahl_spieler: ANZAHL_SPIELER)
spieler = Array.new(ANZAHL_SPIELER) do |i|
  Spieler.new(entscheider: Reinwerfer.new, spiel_informations_sicht: spiel_information.fuer_spieler(i))
end
karten_verwalter = KartenVerwalter.new(karten: Karte.alle, spiel_information: spiel_information)
karten_verwalter.verteilen
auftraege = Karte.alle_normalen.map { |karte| Auftrag.new(karte) }
auftrag_verwalter = AuftragVerwalter.new(auftraege: auftraege, spieler: spieler)
auftrag_verwalter.auftraege_ziehen(anzahl: ANZAHL_AUFTRAEGE)
auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
richter = Richter.new(spiel_information: spiel_information)
spiel = Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information)
spiel.runde until richter.gewonnen || richter.verloren
if richter.verloren
  puts 'Leider wurde das Spiel verloren'
elsif richter.gewonnen
  puts 'Herzliche Gratulation!'
end
