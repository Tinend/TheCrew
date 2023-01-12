# coding: utf-8
# frozen_string_literal: true

# Module für das Anspielen vom Rhinoceros
module SchimpanseZeitdruck
  def zeitdruck
    runden = @spiel_informations_sicht.verbleibende_runden
    return 1000 if runden == 0
    @spiel_informations_sicht.unerfuellte_auftraege.length.to_f / runden
  end
end
