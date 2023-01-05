require 'spiel_ersteller'

# Modul, dass ein Turnier organisiert mit den gegebenen Einstellungen.
module TurnierOrganisator
  def self.organisiere_turnier(anzahl_spieler:, anzahl_spiele:, entscheider_klassen:, seed:, anzahl_auftraege:, reporter:)
    zufalls_generator = Random.new(seed)
    entscheider_klassen.each do |entscheider_klasse|
      persoenlicher_zufalls_generator = zufalls_generator.dup
      punkte = 0
      anzahl_spiele.times do
        spiel = SpielErsteller.erstelle_spiel(anzahl_spieler: ANZAHL_SPIELER, zufalls_generator: persoenlicher_zufalls_generator, entscheider_klasse: entscheider_klasse, anzahl_auftraege: ANZAHL_AUFTRAEGE, reporter: reporter)
        resultat = spiel.spiele
        punkte += 1 if resultat == :gewonnen
      end
      reporter.berichte_punkte(entscheider: entscheider_klasse, punkte: punkte)
    end
  end
end
