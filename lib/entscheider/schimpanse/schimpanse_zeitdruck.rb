# coding: utf-8
# frozen_string_literal: true

# Module für das Anspielen vom Rhinoceros
module SchimpanseZeitdruck
  ZEITDRUCK_SCHWELLE = 0.7
  TRUMPF_STECH_ANNAHME_ZEITDRUCK_SCHWELLE = 1
  
  def zeitdruck
    runden = @spiel_informations_sicht.verbleibende_runden
    return 1000 if runden == 0
    @spiel_informations_sicht.unerfuellte_auftraege.flatten.length.to_f / runden
  end

  def zeitdruck_mit_schwelle
    return 0 if zeitdruck < ZEITDRUCK_SCHWELLE
    zeitdruck
  end

  def trumpf_stech_annahme_zeitdruck?
    zeitdruck >= TRUMPF_STECH_ANNAHME_ZEITDRUCK_SCHWELLE
  end
end
