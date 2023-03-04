# coding: utf-8
# frozen_string_literal: true

# Berechnet den Wert für Karten,
# Wenn eine Farbe abgespielt wird,
# bei der es eigene Aufträge gibt
module ElefantEigeneAuftragStichFarbeAbspielenWert
  def eigene_auftrag_stich_farbe_abspielen_wert(karte:, elefant_rueckgabe:)
    elefant_rueckgabe.symbol = :eigene_auftrag_stich_farbe_abspielen
    elefant_rueckgabe.wert = [0, 1, 0, karte.schlag_wert, 0]
  end
end
