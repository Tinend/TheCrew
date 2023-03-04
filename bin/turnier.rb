#!/usr/bin/ruby
# coding: utf-8
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'entscheider_liste'
require 'turnier_organisator'
require 'turnier_hilfe'
require 'turnier_reporter'

seed_setzer = nil
auftrag_setzer = nil
anzahl_spiele_setzer = nil
entscheider_entferner = []
entscheider_liste_gewaehlt = nil
unendlich_setzer = nil
ARGV.each do |a|
  seed_setzer = a if a[0..1] == '-r'
  auftrag_setzer = a if a[0..1] == '-a'
  entscheider_liste_gewaehlt = a[3..].split(',') if a[0..1] == '-x'
  entscheider_entferner += a[3..].split(',') if a[0..1] == '-y'
  anzahl_spiele_setzer = a if a[0..1] == '-s'
  unendlich_setzer = a if a[0..1] == '-u'
  turnier_hilfe if a[0..1] == '-h'
end

ANZAHL_SPIELER = 4
SEED = if seed_setzer.nil?
         220_357_742_778_267_021_154_878_235_677_688_577_309
       elsif seed_setzer[3..].to_i.zero?
         Random.new_seed
       else
         seed_setzer[3..].to_i
       end
ANZAHL_AUFTRAEGE = if auftrag_setzer.nil?
                     6
                   else
                     auftrag_setzer[3..].to_i
                   end
ANZAHL_SPIELE = if anzahl_spiele_setzer.nil?
                  10_000
                else
                  anzahl_spiele_setzer[3..].to_i
                end

ENTSCHEIDER_MOEGLICH = EntscheiderListe.entscheider_klassen.map(&:to_s)
if entscheider_liste_gewaehlt.nil?
  entscheider_liste_gewaehlt = EntscheiderListe.entscheider_klassen
else
  entscheider_liste_gewaehlt.collect! do |entscheider|
    raise "Der Entscheider #{entscheider} existiert nicht" unless ENTSCHEIDER_MOEGLICH.include?(entscheider)

    Module.const_get entscheider
  end
end
# ENTSCHEIDER = EntscheiderListe.entscheider_klassen.reject do |entscheider|
ENTSCHEIDER = entscheider_liste_gewaehlt.reject do |entscheider|
  entscheider_entferner.any? do |es|
    es == entscheider.to_s
  end
end

puts "Es gibt #{ANZAHL_AUFTRAEGE} Aufträge und jeder Spieler spielt #{ANZAHL_SPIELE} Runden."
einstellungen = TurnierOrganisator::TurnierEinstellungen.new(anzahl_spieler: ANZAHL_SPIELER,
                                                             anzahl_spiele: ANZAHL_SPIELE,
                                                             anzahl_auftraege: ANZAHL_AUFTRAEGE)

i = 0
loop do
  TurnierOrganisator.organisiere_turnier(turnier_einstellungen: einstellungen, seed: SEED + i,
                                         entscheider_klassen: ENTSCHEIDER, reporter: TurnierReporter.new)
  break unless unendlich_setzer
  i += 1
end
