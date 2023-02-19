# coding: utf-8
# frozen_string_literal: true

# Berechnet, wie gut eine Karte zum Anspielen ist,
# wenn mehrere Spieler Aufträge von dieser Farbe hat,
# aber sie selber kein Auftrag ist
module ElefantMultipleAuftragFarbeAnspielenWert
  # rubocop:disable Lint/UnusedMethodArgument
  def multiple_auftrag_farbe_anspielen_wert(karte:)
    # spieler_index = will_blanken_auftrag(farbe: karte.farbe)
    [0, 0, 0, 0, 0]
  end

  def will_blanken_auftrag(farbe: karte.farbe)
    @spiel_informations_sicht.kommunikationen
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
