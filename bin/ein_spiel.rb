#!/usr/bin/ruby
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'entscheider_liste'
require 'ein_spiel_hilfe'
require 'spiel_ersteller'
require 'puts_reporter'
require 'stackprof'

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
SEED = if seed_setzer.nil? || seed_setzer.zero?
         Random.new_seed
       else
         seed_setzer
       end
ANZAHL_AUFTRAEGE = if auftrag_setzer.nil?
                     1
                   else
                     auftrag_setzer.to_i
                   end
ENTSCHEIDER_MOEGLICH = EntscheiderListe.entscheider_klassen.map(&:to_s)
unless entscheider_setzer.nil? || ENTSCHEIDER_MOEGLICH.include?(entscheider_setzer)
  raise 'Diesen Entscheider gibt es nicht!'
end

GEWAEHLTER_ENTSCHEIDER = if entscheider_setzer.nil?
                           ZufallsEntscheider
                         else
                           Module.const_get entscheider_setzer
                         end

zufalls_generator = Random.new(SEED)
spiel = SpielErsteller.erstelle_spiel(anzahl_spieler: ANZAHL_SPIELER, zufalls_generator: zufalls_generator,
                                      entscheider_klasse: GEWAEHLTER_ENTSCHEIDER, anzahl_auftraege: ANZAHL_AUFTRAEGE,
                                      reporter: PutsReporter.new)
spiel.spiele
