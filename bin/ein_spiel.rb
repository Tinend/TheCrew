#!/usr/bin/ruby
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'entscheider/zufalls_entscheider'
require 'entscheider/hase'
require 'entscheider/saeuger'
require 'entscheider/archaeon'
require 'entscheider/rhinoceros'
require 'entscheider/reinwerfer'
require 'entscheider/geschlossene_formel_bot'
require 'ein_spiel_hilfe'
require 'spiel_ersteller'
require 'puts_reporter'

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
ENTSCHEIDER_MOEGLICH = %w[Reinwerfer Rhinoceros Hase Saeuger Archaeon ZufallsEntscheider GeschlosseneFormelBot].freeze
unless entscheider_setzer.nil? || ENTSCHEIDER_MOEGLICH.include?(entscheider_setzer)
  raise 'Diesen Entscheider gibt es nicht!'
end

GEWAEHLTER_ENTSCHEIDER = if entscheider_setzer.nil?
                           ZufallsEntscheider
                         else
                           Module.const_get entscheider_setzer
                         end


spiel = SpielErsteller.erstelle_spiel(anzahl_spieler: ANZAHL_SPIELER, seed: SEED, entscheider_klasse: GEWAEHLTER_ENTSCHEIDER, anzahl_auftraege: ANZAHL_AUFTRAEGE, reporter: PutsReporter.new)
resultat = spiel.spiele

