# coding: utf-8

# berechnet Wert für Karten anspielen, wenn
# Karte kein Auftrag ist
module ElefantKeinenAuftragAbspielenWert
  def keinen_auftrag_abspielen_wert(karte:, stich:)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(stich.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe > 0 && fremde_auftraege_mit_farbe > 0
      eigen_und_fremd_auftrag_stich_farbe_abspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe)
    elsif eigene_auftraege_mit_farbe > 0
      eigene_auftrag_stich_farbe_abspielen_wert(karte: karte)
    elsif fremde_auftraege_mit_farbe > 0
      fremden_auftrag_stich_farbe_abspielen_wert(karte: karte)
    else
      keine_auftrag_stich_farbe_abspielen_wert(karte: karte, stich: stich)
    end
  end

  def eigene_auftrag_stich_farbe_abspielen_wert(karte:)
    [0, 1, 0, karte.schlag_wert, 0]
  end

  def fremden_auftrag_stich_farbe_abspielen_wert(karte:)
    [0, 1, 0, -karte.schlag_wert, 0]
  end

  def eigen_und_fremd_auftrag_stich_farbe_abspielen_wert(karte:, auftraege_mit_farbe:)
    [0, 0, 0, 0, 0]
  end

  def keine_auftrag_stich_farbe_abspielen_wert(karte:, stich:)
    if karte.farbe == stich.farbe
      keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte: karte, stich: stich)
    else
      keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte: karte, stich: stich)
    end
  end

  def keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte:, stich:)
    if habe_noch_auftraege?
      eigene_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte: karte)
    else
      fremde_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte: karte, stich: stich)
    end
  end

  def eigene_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte:)
    karte.wert
  end

  def fremde_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      -karte.schlag_wert
    else
      karte.schlag_wert
    end
  end

  def keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte:, stich:)
    if karte.trumpf?
      [0, 0, -1, 0, 0]
    elsif habe_noch_auftraege?
      eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte)
    else
      fremde_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte)
    end
  end

  def eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte:)
    [0, 0, 0, -karte.wert, 0]
    #farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    #if jeder_kann_unterbieten?(karte: karte)
    #  (farb_laenge * 1000 - 1000).to_i + karte.wert
    #else
    #  (farb_laenge * 100 - 100).to_i + karte.wert
    #end
  end

  def fremde_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte:)
    [0, 0, 0, karte.wert, 0]
    #farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    #1200 - karte.wert * 100 - (farb_laenge * 200).to_i
  end
end
