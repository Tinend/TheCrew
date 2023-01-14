# frozen_string_literal: true

# Modul für Entscheider, die die SpielInformationsSicht benutzen.
module SpielInformationsSichtBenutzender
  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end

  def anzahl_spieler
    @spiel_informations_sicht.anzahl_spieler
  end

  def karten
    @spiel_informations_sicht.karten
  end

  def eigene_auftraege
    @spiel_informations_sicht.eigene_auftraege
  end

  def alle_auftraege
    @spiel_informations_sicht.auftraege.flatten
  end
end
