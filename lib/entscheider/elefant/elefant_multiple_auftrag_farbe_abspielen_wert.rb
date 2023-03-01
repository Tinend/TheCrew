# coding: utf-8
# frozen_string_literal: true

# Berechnet, wie gut eine Karte zum Anspielen ist,
# wenn mehrere Spieler Aufträge von dieser Farbe hat,
# aber sie selber kein Auftrag ist
module ElefantMultipleAuftragFarbeAbspielenWert
  def multiple_auftrag_farbe_abspielen_wert(stich:, karte:, elefant_rueckgabe:)
    spieler_index = will_blanken_auftrag(farbe: karte.farbe)
    if spieler_index.nil? || spieler_index.zero?
      eigene_auftrag_stich_farbe_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    else
      fremden_auftrag_stich_farbe_abspielen_wert(stich: stich, karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    end
  end
end
