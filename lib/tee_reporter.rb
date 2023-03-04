# frozen_string_literal: true

require_relative 'reporter'

# Dieser Reporter berichtet all seinen subreportern weiter.
class TeeReporter < Reporter
  def initialize(subreporter)
    super()
    @subreporter = subreporter
  end

  attr_reader :subreporter

  def berichte_start_situation(karten:, auftraege:)
    @subreporter.each do |r|
      r.berichte_start_situation(karten: karten, auftraege: auftraege)
    end
  end

  def berichte_kommunikation(spieler_index:, kommunikation:)
    @subreporter.each do |r|
      r.berichte_kommunikation(spieler_index: spieler_index, kommunikation: kommunikation)
    end
  end

  def berichte_stich(stich:, vermasselte_auftraege:, erfuellte_auftraege:)
    @subreporter.each do |r|
      r.berichte_stich(stich: stich, vermasselte_auftraege: vermasselte_auftraege,
                       erfuellte_auftraege: erfuellte_auftraege)
    end
  end

  def berichte_gewonnen
    @subreporter.each(&:berichte_gewonnen)
  end

  def berichte_verloren
    @subreporter.each(&:berichte_verloren)
  end

  def berichte_spiel_statistiken(statistiken)
    @subreporter.each do |r|
      r.berichte_spiel_statistiken(statistiken)
    end
  end

  def berichte_gesamt_statistiken(gesamt_statistiken:, gewonnen_statistiken:, verloren_statistiken:)
    @subreporter.each do |r|
      r.berichte_gesamt_statistiken(gesamt_statistiken: gesamt_statistiken, gewonnen_statistiken: gewonnen_statistiken,
                                    verloren_statistiken: verloren_statistiken)
    end
  end

  # Berichtet die Anzahl Punkte, die ein Entscheider nach mehreren Spielen gemacht hat
  def berichte_punkte(entscheider:, punkte:)
    @subreporter.each do |r|
      r.berichte_punkte(entscheider: entscheider, punkte: punkte)
    end
  end
end
