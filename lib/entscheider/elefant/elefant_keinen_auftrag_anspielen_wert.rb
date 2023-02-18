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
      keine_auftrag_farbe_anspielen_wert(karte: karte)
    end
  end

  def eigene_auftrag_farbe_anspielen_wert(karte:)
    auftrag = tiefster_eigener_auftrag_auf_fremder_hand_mit_farbe(karte.farbe)
    if auftrag.nil?
      [0, 0, 0, karte.wert, 0]
    else
      eigene_auftrag_farbe_fremde_hand_anspielen_wert(karte: karte, auftrag: auftrag)
    end
  end

  def eigene_auftrag_farbe_fremde_hand_anspielen_wert(karte:, auftrag:)
    if karte.wert > auftrag.karte.wert
      [0, 1, 3, karte.wert, 0]
    elsif habe_hohe_karte_mit_farbe?(farbe: karte.farbe, wert: auftrag.karte.wert) ||
          kurze_farbe?(farbe: karte.farbe)
      [0, 0, 1, 0, 0]
    else
      [0, 0, -1, 0, 0]
    end
  end

  def fremden_auftrag_farbe_anspielen_wert(karte:)
    [0, 1, 0, 0, -karte.wert, 0]
  end

  def eigen_und_fremd_auftrag_farbe_anspielen_wert(karte:, auftraege_mit_farbe:)
    [0, 0, 0, 0, 0]
  end

  def keine_auftrag_farbe_anspielen_wert(karte:)
    if karte.trumpf?
      [0, 0, -1, 0, 0]
    elsif habe_noch_auftraege?
      eigene_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte: karte)
    else
      fremde_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte: karte)
    end
  end

  def eigene_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte:)
    farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    if jeder_kann_unterbieten?(karte: karte)
      [0, 0, farb_laenge - 1, karte.wert, 0]
    else
      [0, 0, farb_laenge * 0.1 - 0.1, karte.wert, 0]
    end
  end

  def fremde_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte:)
    farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    [0, 0, 12 - karte.wert - farb_laenge * 2, 0, 0]
  end
end
