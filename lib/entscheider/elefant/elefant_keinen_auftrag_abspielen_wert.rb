# coding: utf-8
# berechnet Wert für Karten anspielen, wenn
# Karte kein Auftrag ist
module ElefantKeinenAuftragAbspielenWert
  def keinen_auftrag_abspielen_wert(karte:, stich:)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(stich.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe > 0 && fremde_auftraege_mit_farbe > 0
      eigen_und_fremd_auftrag_farbe_abspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe)
    elsif eigene_auftraege_mit_farbe > 0
      eigene_auftrag_farbe_abspielen_wert(karte: karte)
    elsif fremde_auftraege_mit_farbe > 0
      fremden_auftrag_farbe_abspielen_wert(karte: karte)
    else
      keine_auftrag_farbe_abspielen_wert
    end
  end

  def eigene_auftrag_farbe_abspielen_wert(karte:)
    karte.schlag_wert + 10_000
  end

  def fremden_auftrag_farbe_abspielen_wert(karte:)
    10_000 - karte.schlag_wert
  end

  def eigen_und_fremd_auftrag_farbe_abspielen_wert(karte:, auftraege_mit_farbe:)
    0
  end

  def keine_auftrag_farbe_abspielen_wert
    0
  end
end
