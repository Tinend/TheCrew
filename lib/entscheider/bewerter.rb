# frozen_string_literal: true

# Bewerter, der für eine AI eine Spiel Information bewertet.
class Bewerter
  VERLOREN_BEWERTUNG = -1000.0
  NICHT_KOMMUNIZIERT_VERLOREN_BEWERTUNG = -100.0
  GEWONNEN_BEWERTUNG = 1000.0
  NICHT_KOMMUNIZIERT_GEWONNEN_BEWERTUNG = 1.0
  EIGENER_AUFTRAG_ERFUELLT_BEWERTUNG = 50.0
  ANDERER_AUFTRAG_ERFUELLT_BEWERTUNG = 40.0

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
    bewertung = EIGENER_AUFTRAG_ERFUELLT_BEWERTUNG * spiel_informations_sicht.auftraege[0].count(&:erfuellt)
    bewertung += ANDERER_AUFTRAG_ERFUELLT_BEWERTUNG * spiel_informations_sicht.auftraege[1..-1].flatten.count(&:erfuellt)
    bewertung
  end
end
