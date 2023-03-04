# coding: utf-8

# Berechnet den Wert für Karten,
# Wenn eine Farbe abgespielt wird,
# bei der es fremde Aufträge gibt
module ElefantFremdeAuftragStichFarbeAbspielenWert

  def fremde_auftrag_stich_farbe_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if (stich.farbe == karte.farbe) && karte.schlaegt?(stich.staerkste_karte)
      elefant_rueckgabe.symbol = :fremde_auftrag_stich_farbe_abspielen_schlagen
      elefant_rueckgabe.wert = [0, 0, -1, karte.schlag_wert, 0]
    elsif karte.schlaegt?(stich.staerkste_karte)
      elefant_rueckgabe.symbol = :fremde_auftrag_stich_farbe_abspielen_trumpf
      elefant_rueckgabe.wert = [0, 0, -2, karte.schlag_wert, 0]
    else
      elefant_rueckgabe.symbol = :fremde_auftrag_stich_farbe_abspielen_unterbieten
      elefant_rueckgabe.wert = [0, 0, 1, karte.schlag_wert, 0]
    end
  end

end
