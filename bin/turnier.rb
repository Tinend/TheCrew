#!/usr/bin/ruby
# coding: utf-8
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
require 'entscheider/geschlossene_formel_bot'
require 'spieler'
require 'spiel'
require 'auftrag_verwalter'
require 'karten_verwalter'
require 'auftrag'
require 'karte'
require 'turnier_hilfe'

seed_setzer = nil
auftrag_setzer = nil
anzahl_spiele_setzer = nil
entscheider_setzer = []
ARGV.each do |a|
  seed_setzer = a if a[0..1] == '-r'
  auftrag_setzer = a if a[0..1] == '-a'
  entscheider_setzer.push(a) if a[0..1] == '-x'
  anzahl_spiele_setzer = a if a[0..1] == '-s'
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
ENTSCHEIDER = [Reinwerfer, Rhinoceros, Hase, Saeuger, Archaeon, ZufallsEntscheider,
               GeschlosseneFormelBot].delete_if do |entscheider|
  entscheider_setzer.any? do |es|
    es[3..] == entscheider.to_s
  end
end

zufalls_generator = Random.new(SEED)

puts "Es gibt #{ANZAHL_AUFTRAEGE} Aufträge und jeder Spieler spielt #{ANZAHL_SPIELE} Runden."
ENTSCHEIDER.each do |entscheider|
  persoenlicher_zufalls_generator = zufalls_generator.dup
  punkte = 0
  ANZAHL_SPIELE.times do |_i|
    spiel_information = SpielInformation.new(anzahl_spieler: ANZAHL_SPIELER)
    spieler = Array.new(ANZAHL_SPIELER) do |i|
      Spieler.new(entscheider: entscheider.new, spiel_informations_sicht: spiel_information.fuer_spieler(i))
    end
    karten_verwalter = KartenVerwalter.new(karten: Karte.alle.dup, spiel_information: spiel_information)
    karten_verwalter.verteilen(zufalls_generator: persoenlicher_zufalls_generator)
    auftraege = Karte.alle_normalen.map { |karte| Auftrag.new(karte) }
    auftrag_verwalter = AuftragVerwalter.new(auftraege: auftraege, spieler: spieler)
    auftrag_verwalter.auftraege_ziehen(anzahl: ANZAHL_AUFTRAEGE, zufalls_generator: persoenlicher_zufalls_generator)
    auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
    richter = Richter.new(spiel_information: spiel_information)
    spiel = Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information, ausgeben: false)
    spiel.runde(ausgeben: false) until richter.gewonnen || richter.verloren
    punkte += 1 if richter.gewonnen
  end
  puts "#{entscheider} hat #{punkte} Punkte geholt."
end
