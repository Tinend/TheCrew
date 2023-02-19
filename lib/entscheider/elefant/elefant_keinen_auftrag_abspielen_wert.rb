# coding: utf-8
# frozen_string_literal: true

# berechnet Wert für Karten anspielen, wenn
# Karte kein Auftrag ist
module ElefantKeinenAuftragAbspielenWert
  def keinen_auftrag_abspielen_wert(karte:, stich:)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(stich.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe.positive? && fremde_auftraege_mit_farbe.positive?
      eigen_und_fremd_auftrag_stich_farbe_abspielen_wert # (karte: karte, auftraege_mit_farbe: auftraege_mit_farbe)
    elsif eigene_auftraege_mit_farbe.positive?
      eigene_auftrag_stich_farbe_abspielen_wert(karte: karte)
    elsif fremde_auftraege_mit_farbe.positive?
      fremden_auftrag_stich_farbe_abspielen_wert(karte: karte, stich: stich)
    else
      keine_auftrag_stich_farbe_abspielen_wert(karte: karte, stich: stich)
    end
  end

  def eigene_auftrag_stich_farbe_abspielen_wert(karte:)
    [0, 1, 0, karte.schlag_wert, 0]
  end

  def fremden_auftrag_stich_farbe_abspielen_wert(karte:, stich:)
    if (stich.farbe == karte.farbe) && karte.schlaegt?(stich.staerkste_karte)
      [0, 0, -1, karte.schlag_wert, 0]
    elsif karte.schlaegt?(stich.staerkste_karte)
      [0, 0, -2, karte.schlag_wert, 0]
    else
      [0, 0, 1, karte.schlag_wert, 0]
    end
  end

  # (karte:, auftraege_mit_farbe:)
  def eigen_und_fremd_auftrag_stich_farbe_abspielen_wert
    [0, 0, 0, 0, 0]
  end

  def keine_auftrag_stich_farbe_abspielen_wert(karte:, stich:)
    if karte.farbe == stich.farbe
      keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte: karte, stich: stich)
    else
      keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte: karte)
    end
  end

  def keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte:, stich:)
    if habe_noch_auftraege?
      eigene_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte: karte, stich: stich)
    else
      fremde_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte: karte, stich: stich)
    end
  end

  def eigene_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      [0, 0, 1, -karte.wert, 0]
    else
      [0, 0, -1, -karte.wert, 0]
    end
  end

  def fremde_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      [0, 0, -1, karte.schlag_wert, 0]
    else
      [0, 0, 1, karte.schlag_wert, 0]
    end
  end

  def keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte:)
    if karte.trumpf?
      [0, 0, -2, 0, 0]
    elsif habe_noch_auftraege?
      eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte)
    else
      fremde_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte)
    end
  end

  def eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte:)
    if @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].empty?
      [0, 0, 0, -karte.wert, 0]
    else
      verlorene_farbe_mit_auftrag_abspielen_wert(karte: karte)
    end
  end

  def verlorene_farbe_mit_auftrag_abspielen_wert(karte:)
    min_auftrag = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].min_by do |auftrag|
      auftrag.karte.wert
    end
    max_karte = @spiel_informations_sicht.karten_mit_farbe(karte.farbe).max
    if max_karte.wert >= min_auftrag.karte.wert
      [0, 0, -1, -karte.wert, 0]
    else
      [0, 0, 1, 0, 0]
    end
  end

  def fremde_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte:)
    if @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.empty?
      [0, 0, 0, karte.wert, 0]
    else
      [0, 0, 1, karte.wert, 0]
    end
  end
end
