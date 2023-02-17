# coding: utf-8
# berechnet Wert für Karten anspielen, wenn
# Karte ein eigener Auftrag ist
module ElefantEigenenAuftragAbspielenWert
  def eigenen_auftrag_abspielen_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      eigenen_auftrag_abspielen_schlaegt_stich_wert(karte: karte, stich: stich)
    else
      -10_000
    end
  end

  def eigenen_auftrag_abspielen_schlaegt_stich_wert(karte:, stich:)
    end_index = @spiel_informations_sicht.anzahl_spieler - 1 - stich.length
    if jeder_kann_unterbieten?(karte: karte, end_index: end_index)
      10_100
    else
      -10_000
    end
  end
end
