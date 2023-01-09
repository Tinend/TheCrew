# coding: utf-8
# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

# gehört zu Rhinoceros
# legt eine Karte auf einen Stich
module RhinocerosAbspielen
  # rubocop:enable Metrics/ModuleLength
  def ist_auftrag_von_spieler?(karte:, spieler_index:)
    @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? { |auftrag| auftrag.karte == karte }
  end

  def braucht_stich_selbst_wert(karte:, stich:)
    if ist_auftrag_von_spieler?(karte: karte, spieler_index: 0) && karte.schlaegt?(stich.staerkste_karte)
      (12 * karte.wert) - 5
    elsif karte.schlaegt?(stich.staerkste_karte) && karte.trumpf?
      72 + karte.wert
    elsif karte.schlaegt?(stich.staerkste_karte) && !ist_auftrag?(karte: karte)
      8 * karte.wert
    else
      -10_000
    end
  end

  def kein_auftrag_von_auftrag_nehmer(karte:, stich:)
    if karte.trumpf? && karte.schlaegt?(stich.staerkste_karte)
      - 100 - karte.wert
    elsif karte.schlaegt?(stich.staerkste_karte)
      - 10 - karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length.zero?
      karte.wert
    else
      - karte.wert
    end
  end

  def anderer_braucht_stich_wert(spieler_index:, karte:, stich:)
    if (stich.gespielte_karten.length + spieler_index >= @spiel_informations_sicht.anzahl_spieler) &&
       karte.schlaegt?(stich.staerkste_karte)
      - 10_000
    elsif ((karte.wert >= 7) || karte.trumpf?) && karte.schlaegt?(stich.staerkste_karte)
      - 3_000 * (karte.wert - 6)
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: spieler_index)
      100
    else
      kein_auftrag_von_auftrag_nehmer(karte: karte, stich: stich)
    end
  end

  def ist_auftrag?(karte:)
    @spiel_informations_sicht.auftraege.each do |auftrag_liste|
      return true if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
    end
    false
  end

  def spieler_index_von_auftrag(karte:)
    @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
      return spieler_index if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
    end
    raise 'Bitte diese Funktion nur verwenden, wenn es ein Auftrag ist'
  end

  def auftrag_nehmer_kommt_noch_dran?(stich:, karte:)
    stich.gespielte_karten.length + spieler_index_von_auftrag(karte: karte) >= @spiel_informations_sicht.anzahl_spieler
  end

  def auftrags_karte_schlaegt_legen_wert(karte:, stich:)
    if auftrag_nehmer_kommt_noch_dran?(stich: stich, karte: karte)
      - 10_000
    elsif karte.wert == 9
      - 7_000
    elsif karte.wert >= 7
      - 30 * (karte.wert - 6)
    else
      10 - karte.wert
    end
  end

  def auftraggeber_hat_staerkste_karte_wert(stich)
    if (stich.staerkste_karte.wert > 6) || stich.staerkste_karte.trumpf?
      10_000
    else
      (stich.staerkste_karte.wert - 5) * 1000
    end
  end

  def auftrags_karte_legen_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      auftrags_karte_schlaegt_legen_wert(karte: karte, stich: stich)
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: stich.staerkste_gespielte_karte.spieler_index)
      auftraggeber_hat_staerkste_karte_wert(stich)
    elsif auftrag_nehmer_kommt_noch_dran?(stich: stich, karte: karte)
      - 10_000
    elsif stich.staerkste_karte.wert > 6
      -3_000 * (stich.staerkste_karte.wert - 6)
    elsif stich.staerkste_karte.trumpf?
      -9_000 - (200 * stich.staerkste_karte.wert)
    else
      - stich.staerkste_karte.wert - 20
    end
  end

  def habe_noch_auftraege_wert(stich:, karte:)
    if karte.schlaegt?(stich.staerkste_karte) && karte.trumpf?
      10 + karte.wert
    elsif karte.schlaegt?(stich.staerkste_karte)
      karte.wert
    elsif karte.trumpf?
      - 10 - karte.wert
    else
      - karte.wert
    end
  end

  def keine_auftraege_von_karten_farbe_wert(stich:, karte:)
    if @spiel_informations_sicht.unerfuellte_auftraege[0].length.positive?
      habe_noch_auftraege_wert(stich: stich, karte: karte)
    elsif !karte.schlaegt?(stich.staerkste_karte) && karte.trumpf?
      10 + karte.wert
    elsif !karte.schlaegt?(stich.staerkste_karte)
      karte.wert
    elsif karte.trumpf?
      - 10 - karte.wert
    else
      - karte.wert
    end
  end

  def kein_auftrag_gelegt_wert(karte:, stich:, spieler_index:)
    if spieler_index.zero?
      braucht_stich_selbst_wert(karte: karte, stich: stich)
    else
      anderer_braucht_stich_wert(spieler_index: spieler_index, karte: karte, stich: stich)
    end
  end

  def nur_noch_ich_habe_farb_auftraege?(karte:)
    anzahl_farb_auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length
    anzahl_eigene_farb_auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length
    anzahl_farb_auftraege == anzahl_eigene_farb_auftraege
  end

  def nur_noch_ich_habe_farb_auftraege_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      karte.wert
    else
      - karte.wert
    end
  end

  def spieler_mit_index_auftrag_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      (6 * karte.wert) - 3
    else
      - 10_000
    end
  end

  def kein_anderer_hat_farb_auftraege_wert(karte:, stich:)
    if nur_noch_ich_habe_farb_auftraege?(karte: karte)
      nur_noch_ich_habe_farb_auftraege_wert(karte: karte, stich: stich)
    else
      karte.wert
    end
  end

  def keine_eigenen_auftraege_mit_farbe?(farbe)
    @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[0].length.zero?
  end

  def keine_auftraege_mit_farbe?(farbe)
    @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe).flatten.length.zero?
  end

  def kein_auftrag_wert(karte:, stich:)
    if keine_eigenen_auftraege_mit_farbe?(karte.farbe) && !karte.schlaegt?(stich.staerkste_karte) &&
       !keine_auftraege_mit_farbe?(karte.farbe)
      karte.wert
    elsif keine_eigenen_auftraege_mit_farbe?(karte.farbe) && !keine_auftraege_mit_farbe?(karte.farbe)
      - karte.wert
    elsif keine_auftraege_mit_farbe?(karte.farbe)
      keine_auftraege_von_karten_farbe_wert(stich: stich, karte: karte)
    else
      kein_anderer_hat_farb_auftraege_wert(karte: karte, stich: stich)
    end
  end

  # wie gut eine Karte zum drauflegen geeignet ist
  def abspiel_wert_karte(karte, stich)
    spieler_index = finde_auftrag(stich)
    if !spieler_index.nil?
      kein_auftrag_gelegt_wert(karte: karte, stich: stich, spieler_index: spieler_index)
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: 0)
      spieler_mit_index_auftrag_wert(karte: karte, stich: stich)
    elsif ist_auftrag?(karte: karte)
      auftrags_karte_legen_wert(karte: karte, stich: stich)
    else
      kein_auftrag_wert(karte: karte, stich: stich)
    end
  end
end
