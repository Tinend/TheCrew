class Bewerter
  VERLOREN_BEWERTUNG = -1000
  NICHT_KOMMUNIZIERT_VERLOREN_BEWERTUNG = -100
  GEWONNEN_BEWERTUNG = 1000
  NICHT_KOMMUNIZIERT_GEWONNEN_BEWERTUNG = 1

  def bewerte_verloren(spiel_informations_sicht)
    bewertung = VERLOREN_BEWERTUNG
    bewertung += NICHT_KOMMUNIZIERT_VERLOREN_BEWERTUNG unless spiel_informations_sicht.kommunikationen[0]
    bewertung
  end

  def bewerte_gewonnen(spiel_informations_sicht)
    bewertung = GEWONNEN_BEWERTUNG
    bewertung += NICHT_KOMMUNIZIERT_GEWONNEN_BEWERTUNG unless spiel_informations_sicht.kommunikationen[0]
    bewertung
  end

  def bewerte(spiel_informations_sicht)
    -spiel_informations_sicht.alle_auftraege.length
  end
end
