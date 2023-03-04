# coding: utf-8
# frozen_string_literal: true

require 'spiel_ersteller'
require 'statistiker'

# Modul, dass ein Turnier organisiert mit den gegebenen Einstellungen.
module TurnierOrganisator
  # Einstellungen für ein Turnier, die unabhängig von den Spielern sind.
  class TurnierEinstellungen
    def initialize(anzahl_spieler:,
                   anzahl_spiele:,
                   anzahl_auftraege:)
      @anzahl_spieler = anzahl_spieler
      @anzahl_spiele = anzahl_spiele
      @anzahl_auftraege = anzahl_auftraege
    end

    attr_reader :anzahl_spieler, :anzahl_spiele, :anzahl_auftraege
  end

  def self.organisiere_turnier(turnier_einstellungen:,
                               entscheider_klassen:,
                               seed:,
                               reporter:)
    zufalls_generator = Random.new(seed)
    entscheider_klassen.each do |entscheider_klasse|
      persoenlicher_zufalls_generator = zufalls_generator.dup
      punkte = 0
      statistiker = Statistiker.new
      turnier_einstellungen.anzahl_spiele.times do
        spiel = SpielErsteller.erstelle_spiel(anzahl_spieler: turnier_einstellungen.anzahl_spieler,
                                              zufalls_generator: persoenlicher_zufalls_generator,
                                              entscheider_klasse: entscheider_klasse,
                                              anzahl_auftraege: turnier_einstellungen.anzahl_auftraege,
                                              reporter: reporter,
                                              statistiker: statistiker)
        resultat = spiel.spiele
        punkte += 1 if resultat == :gewonnen
      end
      reporter.berichte_punkte(entscheider: entscheider_klasse, punkte: punkte)
      reporter.berichte_gesamt_statistiken(gesamt_statistiken: statistiker.gesamt_statistiken,
                                           gewonnen_statistiken: statistiker.gewonnen_statistiken,
                                           verloren_statistiken: statistiker.verloren_statistiken)
    end
  end
end
