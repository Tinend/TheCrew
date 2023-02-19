# coding: utf-8
# frozen_string_literal: true

# Berechnet den Wert für eine Trumpf Karte
module ElefantTrumpfAnspielenWert
  def trumpf_anspielen_wert(karte:)
    if !habe_noch_auftraege?
      [0, 0, 0, 0, -1]
    elsif nur_noch_ich_habe_truempfe?
      nur_noch_ich_habe_truempfe_trumpf_anspielen_wert(karte: karte)
    else
      andere_haben_noch_truempfe_trumpf_anspielen_wert(karte: karte)
    end
  end

  def nur_noch_ich_habe_truempfe?
    Karte.alle_truempfe.all? do |trumpf|
      @spiel_informations_sicht.karten.any? { |karte| karte == trumpf } ||
        @spiel_informations_sicht.ist_gegangen?(trumpf)
    end
  end

  def andere_haben_noch_truempfe_trumpf_anspielen_wert(karte:)
    if habe_noch_zwei_truempfe? && @spiel_informations_sicht.unerfuellte_auftraege[1..].flatten.empty?
      [0, 0, 1, karte.wert, 0]
    else
      [0, 0, 0, 0, -1]
    end
  end

  def nur_noch_ich_habe_truempfe_trumpf_anspielen_wert(karte:)
    if karte.wert == 4
      [0, 1, 4, 0, -1]
    else
      [0, 1, 4, 0, karte.wert]
    end
  end

  def habe_noch_zwei_truempfe?
    @spiel_informations_sicht.karten_mit_farbe(Farbe::RAKETE).length >= 2
  end
end
