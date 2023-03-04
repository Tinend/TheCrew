# frozen_string_literal: true

require 'weiterleitungs_reporter'

# Diese Klasse berichtet über alles, was im Spiel passiert.
class ReporterMitStatistiker < WeiterleitungsReporter
  def initialize(reporter, statistiker)
    super(reporter)
    @statistiker = statistiker
  end

  def berichte_stich(stich:, vermasselte_auftraege:, erfuellte_auftraege:)
    super
    @statistiker.beachte_stich
  end

  def berichte_gewonnen
    super
    @statistiker.beachte_verloren
    reporter.berichte_spiel_statistiken(@statistiker.letztes_spiel_statistiken)
  end

  def berichte_verloren
    super
    @statistiker.beachte_gewonnen
    reporter.berichte_spiel_statistiken(@statistiker.letztes_spiel_statistiken)
  end
end
