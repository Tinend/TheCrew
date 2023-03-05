# coding: utf-8
# frozen_string_literal: true

# berechnet Wert für Karten anspielen, wenn
# Karte ein eigener Auftrag ist
module ElefantEigenenAuftragAbspielenWert
  def eigenen_auftrag_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if karte.schlaegt?(stich.staerkste_karte)
      eigenen_auftrag_abspielen_schlaegt_stich_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    else
      elefant_rueckgabe.symbol = :eigenen_auftrag_verlieren_abspielen
      elefant_rueckgabe.wert = [0, -1, 0, 0, 0]
    end
  end

  def eigenen_auftrag_abspielen_schlaegt_stich_wert(karte:, stich:, elefant_rueckgabe:)
    end_index = @spiel_informations_sicht.anzahl_spieler - 1 - stich.length
    if jeder_kann_unterbieten?(karte: karte, end_index: end_index)
      elefant_rueckgabe.symbol = :eigenen_auftrag_sicher_abspielen
      elefant_rueckgabe.wert = [0, 1, 1, 0, 0]
    else
      elefant_rueckgabe.symbol = :eigenen_auftrag_unsicher_sicher_abspielen
      elefant_rueckgabe.wert = [0, -1, 0, 0, 0]
    end
  end
end
