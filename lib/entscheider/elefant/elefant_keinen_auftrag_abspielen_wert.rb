# coding: utf-8
# frozen_string_literal: true

require_relative 'elefant_multiple_auftrag_farbe_abspielen_wert'

# berechnet Wert für Karten anspielen, wenn
# Karte kein Auftrag ist
module ElefantKeinenAuftragAbspielenWert
  include ElefantMultipleAuftragFarbeAbspielenWert

  def keinen_auftrag_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(stich.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe.positive? && fremde_auftraege_mit_farbe.positive?
      multiple_auftrag_farbe_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    elsif eigene_auftraege_mit_farbe.positive?
      eigene_auftrag_stich_farbe_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    elsif fremde_auftraege_mit_farbe.positive?
      fremden_auftrag_stich_farbe_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    else
      keine_auftrag_stich_farbe_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigene_auftrag_stich_farbe_abspielen_wert(karte:, elefant_rueckgabe:)
    elefant_rueckgabe.symbol = :eigene_auftrag_stich_farbe_abspielen
    elefant_rueckgabe.wert = [0, 1, 0, karte.schlag_wert, 0]
  end

  def fremden_auftrag_stich_farbe_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
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

  def keine_auftrag_stich_farbe_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if karte.farbe == stich.farbe
      keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    else
      keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def keine_auftrag_stich_farbe_gleiche_farbe_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if habe_noch_auftraege?
      eigene_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte: karte, stich: stich,
                                                                                          elefant_rueckgabe: elefant_rueckgabe)
    else
      fremde_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte: karte, stich: stich,
                                                                                          elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigene_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if karte.schlaegt?(stich.staerkste_karte)
      elefant_rueckgabe.symbol = :eigene_auftraege_mit_fremder_farbe_unterstuetzen_schlagen_abspielen
      elefant_rueckgabe.wert = [0, 0, 1, -karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :eigene_auftraege_mit_fremder_farbe_unterstuetzen_nicht_schlagen_abspielen
      elefant_rueckgabe.wert = [0, 0, -1, -karte.wert, 0]
    end
  end

  def fremde_auftraege_mit_anderer_stich_farbe_gleiche_farbe_unterstuetzen_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
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
      eigene_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    else
      fremde_auftraege_mit_verlorener_farbe_unterstuetzen_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
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
