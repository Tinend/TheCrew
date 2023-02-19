# coding: utf-8
# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

# gehört zu Rhinoceros
# legt eine Karte auf einen Stich
module RhinocerosAbspielen
  # rubocop:enable Metrics/ModuleLength
  def abspielen(stich, waehlbare_karten)
    waehlbare_karten.max_by { |karte| abspiel_wert_karte(karte, stich) }
  end

  def ist_auftrag_von_spieler?(karte:, spieler_index:)
    @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? { |auftrag| auftrag.karte == karte }
  end

  def braucht_stich_selbst_wert(karte:, stich:)
    # puts "#{karte}, 1"
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
    # puts "#{karte}, 2"
    if karte.trumpf? && karte.schlaegt?(stich.staerkste_karte)
      - 100 - karte._wert
    elsif karte.schlaegt?(stich.staerkste_karte)
      - 10 - karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].empty?
      karte.wert
    else
      - karte.wert
    end
  end

  # rubocop:disable Lint/DuplicateBranch
  def anderer_braucht_stich_wert(spieler_index:, karte:, stich:)
    # puts "#{karte}, 3"
    if (stich.gespielte_karten.length + spieler_index >= @spiel_informations_sicht.anzahl_spieler) &&
       karte.schlaegt?(stich.staerkste_karte)
      - 10_000
    elsif karte.schlag_wert >= 7 && karte.schlaegt?(stich.staerkste_karte)
      -3_000 * (karte.schlag_wert - 6)
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: spieler_index)
      100
    elsif ist_auftrag?(karte: karte)
      - 10_000
    else
      kein_auftrag_von_auftrag_nehmer(karte: karte, stich: stich)
    end
  end
  # rubocop:enable Lint/DuplicateBranch:

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
    # puts "#{karte}, 4"
    if auftrag_nehmer_kommt_noch_dran?(stich: stich, karte: karte)
      - 10_000
    elsif karte.trumpf?
      -8_000 - (300 * karte.wert)
    elsif karte.wert == 9
      - 7_000
    elsif karte.wert >= 7
      - 30 * (karte.wert - 6)
    else
      10 - karte.wert
    end
  end

  def auftraggeber_hat_staerkste_karte_wert(stich)
    # puts "KARTE, 5"
    if (stich.staerkste_karte.wert > 6) || stich.staerkste_karte.trumpf?
      10_000
    else
      (stich.staerkste_karte.wert - 5) * 1000
    end
  end

  def auftrags_karte_legen_wert(karte:, stich:)
    # puts "#{karte}, 6"
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
    # puts "#{karte}, 7"
    if karte.schlaegt?(stich.staerkste_karte)
      karte.schlag_wert
    else
      - karte.schlag_wert
    end
  end

  def keine_auftraege_stich_farbe_auftraege_karten_farbe(stich:, karte:)
    # puts "#{karte}, 7.5"
    if ich_habe_noch_farb_auftraege?(farbe: stich.farbe)
      - karte.wert
    else
      karte.wert
    end
  end

  def keine_auftraege_von_stich_farbe_wert(stich:, karte:)
    # puts "#{karte}, 8"
    if !keine_auftraege_mit_farbe?(karte.farbe)
      keine_auftraege_stich_farbe_auftraege_karten_farbe(stich: stich, karte: karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].length.positive?
      habe_noch_auftraege_wert(stich: stich, karte: karte)
    elsif !karte.schlaegt?(stich.staerkste_karte)
      karte.schlag_wert
    else
      - karte.schlag_wert
    end
  end

  def kein_auftrag_gelegt_wert(karte:, stich:, spieler_index:)
    # puts "#{karte}, 8.5"
    if spieler_index.zero?
      braucht_stich_selbst_wert(karte: karte, stich: stich)
    else
      anderer_braucht_stich_wert(spieler_index: spieler_index, karte: karte, stich: stich)
    end
  end

  def nur_noch_ich_habe_farb_auftraege?(farbe:)
    anzahl_farb_auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe).flatten.length
    anzahl_eigene_farb_auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[0].length
    anzahl_farb_auftraege == anzahl_eigene_farb_auftraege
  end

  # rubocop:disable Lint/DuplicateBranch
  def nur_noch_ich_habe_farb_auftraege_wert(karte:, stich:)
    # puts "#{karte}, 9"
    if karte.schlaegt?(stich.staerkste_karte)
      karte.schlag_wert
    elsif ich_habe_noch_farb_auftraege?(farbe: karte.farbe)
      - karte.schlag_wert - 100
    elsif keine_auftraege_mit_farbe?(karte.farbe)
      - karte.schlag_wert
    else
      karte.schlag_wert
    end
  end
  # rubocop:enable Lint/DuplicateBranch

  def spieler_mit_index_auftrag_wert(karte:, stich:)
    # puts "#{karte}, 10"
    if karte.schlaegt?(stich.staerkste_karte)
      (6 * karte.schlag_wert) - 3
    else
      - 10_000
    end
  end

  def ich_habe_noch_farb_auftraege?(farbe:)
    !@spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[0].empty?
  end

  # rubocop:disable Lint/DuplicateBranch
  def ich_und_andere_haben_farb_auftraege_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte)
      karte.schlag_wert
    elsif karte.farbe == stich.farbe || keine_auftraege_mit_farbe?(stich.farbe) ||
          karte.trumpf?
      - karte.schlag_wert
    elsif ich_habe_noch_farb_auftraege?(farbe: karte.farbe)
      - karte.schlag_wert - 20
    else
      karte.schlag_wert
    end
  end
  # rubocop:enable Lint/DuplicateBranch

  def wahrscheinlich_noch_farb_auftraege_wert(karte:, stich:)
    # puts "#{karte}, 11"
    if keine_auftraege_mit_farbe?(stich.farbe)
      keine_auftraege_von_stich_farbe_wert(stich: stich, karte: karte)
    elsif nur_noch_ich_habe_farb_auftraege?(farbe: stich.farbe)
      nur_noch_ich_habe_farb_auftraege_wert(karte: karte, stich: stich)
    elsif ich_habe_noch_farb_auftraege?(farbe: stich.farbe)
      ich_und_andere_haben_farb_auftraege_wert(karte: karte, stich: stich)
    elsif karte.schlaegt?(stich.staerkste_karte) || ich_habe_noch_farb_auftraege?(farbe: karte.farbe)
      - karte.schlag_wert
    else
      karte_schlaegt_nicht_ich_keine_auftrage_mehr(karte)
    end
  end

  def karte_schlaegt_nicht_ich_keine_auftrage_mehr(karte)
    if karte.trumpf? || !@spiel_informations_sicht.unerfuellte_auftraege[0].empty?
      - karte.wert
    else
      karte.wert
    end
  end

  def keine_eigenen_auftraege_mit_farbe?(farbe)
    @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[0].empty?
  end

  def keine_auftraege_mit_farbe?(farbe)
    @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe).flatten.empty?
  end

  def kein_auftrag_im_stich_wert(karte:, stich:)
    # puts "#{karte}, 12"
    if keine_eigenen_auftraege_mit_farbe?(karte.farbe) && !karte.schlaegt?(stich.staerkste_karte) &&
       !keine_auftraege_mit_farbe?(karte.farbe)
      karte.schlag_wert
    elsif keine_eigenen_auftraege_mit_farbe?(karte.farbe) && !keine_auftraege_mit_farbe?(karte.farbe)
      - karte.schlag_wert
    else
      wahrscheinlich_noch_farb_auftraege_wert(karte: karte, stich: stich)
    end
  end

  # Findet raus, wer einen Auftrag im Stich hat. Wenn niemand einen hat, gibt es 0 zurück
  def finde_auftrag(stich)
    stich.karten.each do |karte|
      @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
        return spieler_index if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
      end
    end
    nil
  end

  def hat_fremden_auftrag?(stich)
    stich.gespielte_karten.any? do |gespielte_karte|
      @spiel_informations_sicht.auftraege[1..].flatten.any? { |auftrag| auftrag.karte == gespielte_karte.karte }
    end
  end

  def hat_eigenen_auftrag?(stich)
    stich.gespielte_karten.any? do |gespielte_karte|
      @spiel_informations_sicht.auftraege[0].any? { |auftrag| auftrag.karte == gespielte_karte.karte }
    end
  end

  # wie gut eine Karte zum drauflegen geeignet ist
  def abspiel_wert_karte(karte, stich)
    spieler_index = finde_auftrag(stich)
    # puts "#{karte}, 13"
    if !spieler_index.nil?
      kein_auftrag_gelegt_wert(karte: karte, stich: stich, spieler_index: spieler_index)
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: 0)
      spieler_mit_index_auftrag_wert(karte: karte, stich: stich)
    elsif ist_auftrag?(karte: karte)
      auftrags_karte_legen_wert(karte: karte, stich: stich)
    else
      kein_auftrag_im_stich_wert(karte: karte, stich: stich)
    end
  end
end
