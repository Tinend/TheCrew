# Diese Klasse berichtet über alles, was im Spiel passiert.
class Reporter
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
end
