# coding: utf-8
# frozen_string_literal: true

# Berechnet den Wert für Karten,
# Wenn eine Farbe abgespielt wird,
# bei der es keine Aufträge gibt
module ElefantKeineAuftragStichFarbeAbspielenWert
  def keine_auftrag_stich_farbe_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if karte.farbe == stich.farbe
      keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte: karte, stich: stich,
                                                             elefant_rueckgabe: elefant_rueckgabe)
    else
      keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if habe_noch_auftraege?
      eigene_auftraege_unterstuetzen_mit_fremder_stich_farbe_abspielen_wert(karte: karte, stich: stich,
                                                                            elefant_rueckgabe: elefant_rueckgabe)
    else
      fremde_auftraege_unterstuetzen_mit_fremder_stich_farbe_abspielen_wert(karte: karte, stich: stich,
                                                                            elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigene_auftraege_unterstuetzen_mit_fremder_stich_farbe_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if karte.schlaegt?(stich.staerkste_karte)
      elefant_rueckgabe.symbol = :eigene_auftraege_mit_fremder_farbe_unterstuetzen_schlagen_abspielen
      elefant_rueckgabe.wert = [0, 0, 1, -karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :eigene_auftraege_mit_fremder_farbe_unterstuetzen_nicht_schlagen_abspielen
      elefant_rueckgabe.wert = [0, 0, -1, -karte.wert, 0]
    end
  end

  def fremde_auftraege_unterstuetzen_mit_fremder_stich_farbe_abspielen_wert(karte:, stich:,
                                                                            elefant_rueckgabe:)
    if karte.schlaegt?(stich.staerkste_karte)
      elefant_rueckgabe.symbol = :fremde_auftraege_mit_fremder_farbe_unterstuetzen_schlagen_abspielen
      elefant_rueckgabe.wert = [0, 0, -1, karte.schlag_wert, 0]
    else
      elefant_rueckgabe.symbol = :fremde_auftraege_mit_fremder_farbe_unterstuetzen_nicht_schlagen_abspielen
      elefant_rueckgabe.wert = [0, 0, 1, karte.schlag_wert, 0]
    end
  end

  def keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte:, elefant_rueckgabe:)
    if karte.trumpf?
      elefant_rueckgabe.symbol = :trumpf_auftragloser_stich_abspielen
      elefant_rueckgabe.wert = [0, 0, -2, 0, 0]
    elsif habe_noch_auftraege?
      eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte,
                                                                         elefant_rueckgabe: elefant_rueckgabe)
    else
      fremde_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte,
                                                                         elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte:, elefant_rueckgabe:)
    if @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].empty?
      elefant_rueckgabe.symbol = :eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen
      elefant_rueckgabe.wert = [0, 0, 0, -karte.wert, 0]
    else
      verlorene_farbe_mit_auftrag_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def verlorene_farbe_mit_auftrag_abspielen_wert(karte:, elefant_rueckgabe:)
    min_auftrag = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].min_by do |auftrag|
      auftrag.karte.wert
    end
    max_karte = @spiel_informations_sicht.karten_mit_farbe(karte.farbe).max
    if max_karte.wert >= min_auftrag.karte.wert
      elefant_rueckgabe.symbol = :verlorene_farbe_mit_holbarer_auftrag_farbe_abspielen
      elefant_rueckgabe.wert = [0, 0, -1, -karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :verlorene_farbe_mit_unholbarer_auftrag_farbe_abspielen
      elefant_rueckgabe.wert = [0, 0, 1, 0, 0]
    end
  end

  def fremde_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte:, elefant_rueckgabe:)
    if @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.empty?
      elefant_rueckgabe.symbol = :verlorene_farbe_mit_fremder_holbarer_auftrag_farbe_abspielen
      elefant_rueckgabe.wert = [0, 0, 0, karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :verlorene_farbe_mit_fremder_unholbarer_auftrag_farbe_abspielen
      elefant_rueckgabe.wert = [0, 0, 1, karte.wert, 0]
    end
  end
end
