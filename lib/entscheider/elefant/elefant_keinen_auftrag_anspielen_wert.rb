# coding: utf-8
# berechnet Wert für Karten anspielen, wenn
# Karte kein Auftrag ist
module ElefantKeinenAuftragAnspielenWert
  def keinen_auftrag_anspielen_wert(karte)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(karte.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe > 0 && fremde_auftraege_mit_farbe > 0
      eigen_und_fremd_auftrag_farbe_anspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe)
    elsif eigene_auftraege_mit_farbe > 0
      eigene_auftrag_farbe_anspielen_wert(karte: karte)
    elsif fremde_auftraege_mit_farbe > 0
      fremden_auftrag_farbe_anspielen_wert(karte: karte)
    else
      keine_auftrag_farbe_anspielen_wert
    end
  end

  def eigene_auftrag_farbe_anspielen_wert(karte:)
    karte.wert + 10
  end

  def fremden_auftrag_farbe_anspielen_wert(karte:)
    10 - karte.wert
  end

  def eigen_und_fremd_auftrag_farbe_anspielen_wert(karte:, auftraege_mit_farbe:)
    0
  end

  def keine_auftrag_farbe_anspielen_wert
    0
  end
end
