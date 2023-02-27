# coding: utf-8
# frozen_string_literal: true

# Berechnet den Wert für eine Trumpf Karte
module ElefantTrumpfAnspielenWert
  def trumpf_anspielen_wert(karte:, elefant_rueckgabe:)
    if !habe_noch_auftraege?
      elefant_rueckgabe.symbol = :keine_eigenen_auftraege_trumpf_anspielen_anspielen
      elefant_rueckgabe.wert = [0, 0, 0, 0, -1]
    elsif nur_noch_ich_habe_truempfe?
      trumpf_monopol_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    else
      andere_haben_noch_truempfe_trumpf_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def nur_noch_ich_habe_truempfe?
    Karte.alle_truempfe.all? do |trumpf|
      @spiel_informations_sicht.karten.any? { |karte| karte == trumpf } ||
        @spiel_informations_sicht.ist_gegangen?(trumpf)
    end
  end

  def andere_haben_noch_truempfe_trumpf_anspielen_wert(karte:, elefant_rueckgabe:)
    if habe_noch_zwei_truempfe? && @spiel_informations_sicht.unerfuellte_auftraege[1..].flatten.empty?
      elefant_rueckgabe.symbol = :auftrag_monopol_trumpf_anspielen
      elefant_rueckgabe.wert = [0, 0, 1, karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :andere_haben_auftraege_trumpf_anspielen
      elefant_rueckgabe.wert = [0, 0, 0, 0, -1]
    end
  end

  def trumpf_monopol_anspielen_wert(karte:, elefant_rueckgabe:)
    if karte.wert == 4
      elefant_rueckgabe.symbol = :trumpf_monopol_4_anspielen
      elefant_rueckgabe.wert = [0, 1, 4, 0, -1]
    else
      elefant_rueckgabe.symbol = :trumpf_monopol_anspielen
      elefant_rueckgabe.wert = [0, 1, 4, 0, karte.wert]
    end
  end

  def habe_noch_zwei_truempfe?
    @spiel_informations_sicht.karten_mit_farbe(Farbe::RAKETE).length >= 2
  end
end
