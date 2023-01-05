require_relative 'reporter'

# Dieser reporter macht nichts.
class LeererReporter < Reporter
  def berichte_start_situation(karten:, auftraege:)
  end

  def berichte_kommunikation(spieler_index:, kommunikation:)
  end

  def berichte_stich(stich:, vermasselte_auftraege:, erfuellte_auftraege:)
  end
  
  def berichte_gewonnen
  end

  def berichte_verloren
  end

  def berichte_punkte(entscheider:, punkte:)
  end
end
