# frozen_string_literal: true

require_relative '../karte'

# Modul, das hilft, gefährliche hohe Karten, die einen Auftrag zerstören könnten,
# zu kommunizieren und anzunehmen, dass andere Spieler das auch tun würden.
module GefaehrlicheKartenKommunizierender
  # Ab diesem Wert sollten alleinstehende oder tiefste Karten immer kommuniziert werden.
  MIN_WARN_KOMMUNIZIER_WERT = 8

  def alle_auftrags_karten
    @spiel_informations_sicht.unerfuellte_auftraege.flatten.map(&:karte)
  end

  # Karten, die einen Auftrag bedrohen.
  def gefaehrliche_karten
    karten.select do |karte|
      !alle_auftrags_karten.include?(karte) && auftrags_karten_anderer(0).any? do |k|
        karte.schlaegt?(k)
      end
    end
  end

  # Karten, die kommuniziert werden sollten.
  def gefaehrliche_hohe_unausweichliche_karten
    gefaehrliche_karten.select do |karte|
      karte.wert >= MIN_WARN_KOMMUNIZIER_WERT && karten.none? do |k|
        k.farbe == karte.farbe && k.wert < karte.wert
      end
    end
  end

  # Karten, die die Farbe angeben und den Stich übernehmen könnten.
  # I.e. ohne Trumpf stechen, aber mit Stichen, die Trumpf ausgespielt haben.
  def uebernehmende_karten(karte)
    (karte.wert + 1..karte.farbe.max_wert).map do |w|
      Karte.new(wert: w, farbe: karte.farbe)
    end
  end

  # Karten, die die Farbe angeben und den Stich nicht übernehmen könnten.
  def unternehmende_karten(karte)
    (karte.farbe.min_wert...karte.wert).map do |w|
      Karte.new(wert: w, farbe: karte.farbe)
    end
  end

  # Spieler Indizes, die nach dem aktuellen Spieler noch dran kommen.
  def spieler_indizes_danach(stich)
    (1...@spiel_informations_sicht.anzahl_spieler - stich.length).to_a
  end

  def andere_spieler_indizes(spieler_index)
    (0...spieler_index).to_a + (spieler_index + 1...@spiel_informations_sicht.anzahl_spieler).to_a
  end

  # Auftragskarten der Leute, die nicht momentane Stichsieger sind.
  def auftrags_karten_anderer(spieler_index)
    andere_spieler_indizes(spieler_index).flat_map do |i|
      @spiel_informations_sicht.unerfuellte_auftraege[i].map(&:karte)
    end
  end

  # Sagt ja, wenn der Sieger des Stichs bleiben sollte, wenn die Spieler danach halbwegs schlau sind.
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize
  def karte_sollte_bleiben?(stich, gespielte_karte)
    # Wenn der Stich gestochen wurde, gehen wir Mal davon aus, dass niemand übersticht.
    # Meistens sollte ein schlauer Mitspieler nicht überstechen. Wenn er muss, hatten wir eh
    # keine Wahl.
    return true if gespielte_karte.karte.trumpf? && !stich.empty? && !stich.farbe.trumpf?

    uebernehmende_karten = uebernehmende_karten(gespielte_karte.karte)
    unternehmende_karten = unternehmende_karten(gespielte_karte.karte)
    rettungs_karten = unternehmende_karten - auftrags_karten_anderer(gespielte_karte.spieler_index)
    spieler_indizes_danach(stich).none? do |spieler_index|
      moegliche_uebernehmende_karten = @spiel_informations_sicht.moegliche_karten(spieler_index) & uebernehmende_karten
      sichere_karten = @spiel_informations_sicht.sichere_karten(spieler_index)

      # Spieler kann nichts zum drüber gehen haben.
      next if moegliche_uebernehmende_karten.empty?

      # Spieler hat sicher was zum drunter gehen.
      # TODO: Wenn wir wegen "hoechste Karte" wissen, dass er etwas tieferes hat, aber nicht _welche_ tiefere,
      # würde er hier nicht merken, dass der andere sicher drunter kann.
      next unless (sichere_karten & rettungs_karten).empty?

      # Spieler hat nur warnpflichtige Karten zum drüber gehen und nichts zum drunter gehen, also ist dies unmöglich
      # (sonst hätte er ja gewarnt)
      hat_nichts_drunter = (sichere_karten & unternehmende_karten).empty?
      # TODO: Implizite Kommunikation wie "7 ist meine tiefste" enthält selbst nachdem die 7 gegangen ist,
      # dass man eine 8 oder 9 hat.
      hat_nicht_gewarnt = (moegliche_uebernehmende_karten & sichere_karten).empty?
      alles_warn_karten = moegliche_uebernehmende_karten.all? { |k| k.wert >= MIN_WARN_KOMMUNIZIER_WERT }
      next if hat_nichts_drunter && hat_nicht_gewarnt && alles_warn_karten

      # Ansonsten müssen wir leider davon ausgehen, dass der Spieler drüber gehen muss.
      true
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize

  def am_zug_beim_kommunizieren?
    return @spiel_informations_sicht.kapitaen_index == 0 if @spiel_informations_sicht.stiche.empty?

    @spiel_informations_sicht.stiche.last.staerkste_gespielte_karte.spieler_index == 0
  end

  def uebernehmbar_durch_andere?(karte)
    andere_spieler_indizes(0).any? do |i|
      @spiel_informations_sicht.moegliche_karten(i).any? do |k|
        k.farbe == karte.farbe && k.schlaegt?(karte)
      end
    end
  end

  def waehle_kommunikation(kommunizierbares)
    # Dieses Modul kommuniziert nie, wenn es selber ausspielt.
    return if am_zug_beim_kommunizieren?

    gefaehrliche_hohe_kommunikation = kommunizierbares.filter do |k|
      !k.hoechste? && gefaehrliche_hohe_unausweichliche_karten.include?(k.karte)
    end
    unless gefaehrliche_hohe_kommunikation.empty?
      @zaehler_manager.erhoehe_zaehler(:gefaehrliche_hohe_kommunikation)
      return gefaehrliche_hohe_kommunikation.sample(random: @zufalls_generator)
    end
    blanke_auftraege_kommunikation = kommunizierbares.filter do |k|
      k.einzige? && alle_auftrags_karten.include?(k.karte) && uebernehmbar_durch_andere?(k.karte)
    end
    return if blanke_auftraege_kommunikation.empty?

    @zaehler_manager.erhoehe_zaehler(:blanke_auftraege_kommunikation)
    return blanke_auftraege_kommunikation.sample(random: @zufalls_generator)
  end
end
