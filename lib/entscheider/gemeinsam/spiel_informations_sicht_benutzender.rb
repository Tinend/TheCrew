# coding: utf-8
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

  def eigene_unerfuellte_auftraege
    @spiel_informations_sicht.eigene_auftraege
  end

  def alle_auftraege
    @spiel_informations_sicht.auftraege.flatten
  end

  def moegliche_karten_von_spieler_mit_farbe(spieler_index:, farbe:)
    @spiel_informations_sicht.bekannte_karten_tracker.moegliche_karten_von_spieler_mit_farbe(
      spieler_index: spieler_index, farbe: farbe
    )
  end
end
