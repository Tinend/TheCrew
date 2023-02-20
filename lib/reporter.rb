# frozen_string_literal: true

require_relative 'statistiker'

# Diese Klasse berichtet über alles, was im Spiel passiert.
class Reporter
  def statistiker
    @statistiker ||= Statistiker.new
  end

  def resette_statistiker
    @statistiker = nil
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

  def berichte_statistiken
    raise NotImplementedError
  end

  # Berichtet die Anzahl Punkte, die ein Entscheider nach mehreren Spielen gemacht hat
  def berichte_punkte(entscheider:, punkte:)
    raise NotImplementedError
  end
end
