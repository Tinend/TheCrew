#!/usr/bin/ruby
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'richter'
require 'spiel_information'
require 'entscheider/zufalls_entscheider'
require 'entscheider/hase'
require 'entscheider/saeuger'
require 'entscheider/archaeon'
require 'entscheider/rhinoceros'
require 'entscheider/reinwerfer'
require 'ein_spiel_hilfe'
require 'spieler'
require 'spiel'
require 'auftrag_verwalter'
require 'karten_verwalter'
require 'auftrag'
require 'karte'


seed_setzer = nil
auftrag_setzer = nil
anzahl_spieler_setzer = nil
entscheider_setzer = nil
ARGV.each do |a|
  seed_setzer = a[3..].to_i if a[0..1] == '-r'
  auftrag_setzer = a[3..] if a[0..1] == '-a'
  entscheider_setzer = a[3..] if a[0..1] == '-x'
  anzahl_spieler_setzer = a[3..] if a[0..1] == '-s'
  ein_spiel_hilfe if a[0..1] == '-h'
end

ANZAHL_SPIELER = if anzahl_spieler_setzer.nil?
                   4
                 else
                   anzahl_spieler_setzer.to_i
                 end
SEED = if seed_setzer.nil? or seed_setzer.zero?
         Random.new_seed
       else
         seed_setzer
       end
ANZAHL_AUFTRAEGE = if auftrag_setzer.nil?
                     1
                   else
                     auftrag_setzer.to_i
                   end
ENTSCHEIDER_MOEGLICH = ["Reinwerfer", "Rhinoceros", "Hase", "Saeuger", "Archaeon", "ZufallsEntscheider"].freeze
raise "Diesen Entscheider gibt es nicht!" unless entscheider_setzer.nil? or ENTSCHEIDER_MOEGLICH.include?(entscheider_setzer)
GEWAEHLTER_ENTSCHEIDER = if entscheider_setzer.nil?
                           ZufallsEntscheider
                         else
                           Module.const_get entscheider_setzer
                         end

zufalls_generator = Random.new(SEED)

spiel_information = SpielInformation.new(anzahl_spieler: ANZAHL_SPIELER)
spieler = Array.new(ANZAHL_SPIELER) do |i|
  Spieler.new(entscheider: GEWAEHLTER_ENTSCHEIDER.new, spiel_informations_sicht: spiel_information.fuer_spieler(i))
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
