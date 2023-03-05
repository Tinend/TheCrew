# coding: utf-8
# frozen_string_literal: true

# Diese Klasse berichtet über alles, was im Spiel passiert.
class Reporter
  def initialize(statistiken_ausgeben: false)
    @statistiken_ausgeben = statistiken_ausgeben
  end

  def berichte_start_situation(karten:, auftraege:)
    raise NotImplementedError
  end

  def berichte_kommunikation(spieler_index:, kommunikation:)
    raise NotImplementedError
  end

  def berichte_stich(stich:, vermasselte_auftraege:, erfuellte_auftraege:)
    raise NotImplementedError
  end

  def berichte_gewonnen
    raise NotImplementedError
  end

  def berichte_verloren
    raise NotImplementedError
  end

  def berichte_spiel_statistiken(statistiken)
    raise NotImplementedError
  end

  def berichte_gesamt_statistiken(gesamt_statistiken:, gewonnen_statistiken:, verloren_statistiken:)
    raise NotImplementedError
  end

  # Berichtet die Anzahl Punkte, die ein Entscheider nach mehreren Spielen gemacht hat
  def berichte_punkte(entscheider:, punkte:)
    raise NotImplementedError
  end
end
