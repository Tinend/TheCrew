# coding: utf-8
# frozen_string_literal: true

require_relative 'zufalls_entscheider'
require_relative '../entscheider'
require_relative '../stich'
require_relative '../karte'
require_relative 'saeuger_auftrag_nehmer'
require_relative 'spiel_informations_sicht_benutzender'

# Entscheider, der immer zufällig entschiedet, was er spielt.
# Wenn er eine Karte reinwerfen kann, die jemand anderem hilft,
# tut er das.
class Reinwerfer < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender

  # Ab diesem Wert sollten alleinstehende oder tiefste Karten immer kommuniziert werden.
  MIN_WARN_KOMMUNIZIER_WERT = 8

  def spieler_indizes_danach(stich)
    (1...@spiel_informations_sicht.anzahl_spieler - stich.length).to_a
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

  # Sagt ja, wenn der Sieger des Stichs bleiben sollte, wenn die Spieler danach halbwegs schlau sind.
  def karte_sollte_bleiben?(stich, gespielte_karte)
    # Wenn der Stich gestochen wurde, gehen wir Mal davon aus, dass niemand übersticht.
    # Meistens sollte ein schlauer Mitspieler nicht überstechen. Wenn er muss, hatten wir eh
    # keine Wahl.
    return true if stich.staerkste_karte.trumpf? && !stich.farbe.trumpf?

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

      # Spieler hat nur warnpflichtige Karten zum drüber gehen und nichts zum drunter gehen, also ist dies unmöglich (sonst hätte er ja gewarnt)
      hat_nichts_drunter = (sichere_karten & unternehmende_karten).empty?
      hat_nicht_gewarnt = (moegliche_uebernehmende_karten & sichere_karten).empty?
      alles_warn_karten = moegliche_uebernehmende_karten.all? { |k| k.wert >= MIN_WARN_KOMMUNIZIER_WERT }
      next if hat_nichts_drunter && hat_nicht_gewarnt && alles_warn_karten

      # Ansonsten müssen wir leider davon ausgehen, dass der Spieler drüber gehen muss.
      true
    end
  end

  # Sagt ja, wenn der Stich bereits eine Auftragskarte des Siegers enthält.
  def toetlicher_stich?(stich)
    # TODO: Wenn es klar ist, dass ein Nachfolger eine Auftragskarte des Siegers reinschmeissen muss,
    # ist es auch ein tötlicher Stich.
    !(stich.karten & auftrags_karten(stich.sieger_index)).empty?
  end

  def auftrags_karten(spieler_index)
    @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].map(&:karte)
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

  def hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
    nicht_schlagende_karten(stich, waehlbare_karten) & auftrags_karten(stich.sieger_index)
  end

  def hilfreiche_karten_fuer_nehmende_karte(stich, nehmende_karte, waehlbare_karten)
    nehmbare_karten(stich, nehmende_karte, waehlbare_karten) & auftrags_karten(nehmende_karte.spieler_index)
  end

  # Karten von Spielern danach, die den Stich nehmen könnten.
  def nehmende_karten_danach(stich)
    raise 'Die übernehm Logik funktioniert nicht für leere Stiche.' if stich.empty?

    spieler_indizes_danach(stich).flat_map do |i|
      @spiel_informations_sicht.sichere_karten(i).filter_map do |k|
        next unless k.schlaegt?(stich.staerkste_karte)

        Stich::GespielteKarte.new(karte: k, spieler_index: i)
      end
    end
  end

  # Karten, die man in diesem Stich rein werfen kann, die aber später für andere Aufträge gefährlich sein könnten.
  # TODO: Manchmal sind diese Karten eigentlich ungefährlich, wenn man sie schützen kann. Das sollte man einprogrammieren.
  def gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten)
    nicht_schlagende_karten(stich, waehlbare_karten) & gefaehrliche_karten
  end

  # Karten, die man in diesem Stich rein werfen kann, die aber später für andere Aufträge gefährlich sein könnten.
  # TODO: Manchmal sind diese Karten eigentlich ungefährlich, wenn man sie schützen kann. Das sollte man einprogrammieren.
  def gefaehrliche_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
    nehmbare_karten(stich, nehmende_karte, waehlbare_karten) & gefaehrliche_karten
  end

  # Karten, die den Stich nicht schlagen und auch nicht machen, dass wir sofort verlieren.
  def undestruktive_nicht_schlagende_karten(stich, waehlbare_karten)
    nicht_schlagende_karten(stich, waehlbare_karten) - auftrags_karten_anderer(stich.sieger_index)
  end

  # Karten, die die gegebene Karte nicht hindern, den Stich zu schlagen
  # und auch nicht machen, dass wir sofort verlieren.
  def undestruktive_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
    nehmbare_karten(stich, nehmende_karte, waehlbare_karten) - auftrags_karten_anderer(nehmende_karte.spieler_index)
  end

  def nicht_schlagende_karten(stich, waehlbare_karten)
    waehlbare_karten.reject { |k| k.schlaegt?(stich.staerkste_karte) }
  end

  def nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
    waehlbare_karten.select { |k| !k.schlaegt?(stich.staerkste_karte) || nehmende_karte.karte.schlaegt?(k) }
  end

  def karten
    @spiel_informations_sicht.karten
  end

  def alle_auftrags_karten
    @spiel_informations_sicht.unerfuellte_auftraege.flatten.map(&:karte)
  end

  def gefaehrliche_karten
    karten.select do |karte|
      !alle_auftrags_karten.include?(karte) && auftrags_karten_anderer(0).any? do |k|
        karte.schlaegt?(k)
      end
    end
  end

  def gefaehrliche_hohe_unausweichliche_karten
    gefaehrliche_karten.select do |karte|
      karte.wert >= MIN_WARN_KOMMUNIZIER_WERT && karten.none? do |k|
        k.farbe == karte.farbe && k.wert < karte.wert
      end
    end
  end

  # Karten, die einen eigenen Auftrag erfüllen.
  def auftrags_nehmende_karten(waehlbare_karten, stich)
    # Eigene Auftragskarten
    gute_karten = auftrags_karten(0)

    # Kandidatenkarten, die den Stich nehmen könnten.
    kandidaten = waehlbare_karten.select { |k| k.schlaegt?(stich.staerkste_karte) & karte_sollte_bleiben?(stich, Stich::GespielteKarte.new(karte: k, spieler_index: 0)) }
    return [] if kandidaten.empty?

    # Kandidatenkarten, gleichzeitig Auftragskarten sind (beste Variante).
    gute_kandidaten = kandidaten & gute_karten
    return gute_kandidaten unless gute_kandidaten.empty?

    # Kandidaten, die einen Auftrag erfüllen, indem sie eine bisher im Stich vorhandene Karte zeigen.
    return [] if (stich.karten & gute_karten).empty?

    kandidaten
  end

  def waehle_karte(stich, waehlbare_karten)
    return waehlbare_karten.first if waehlbare_karten.length == 1
    return waehlbare_karten.sample(random: @zufalls_generator) if stich.empty?

    # Wenn dieser Stich eh schon tötlich ist, wenn er nicht durchkommt.
    if toetlicher_stich?(stich)
      # Wenn möglich eine Auftragskarte rein schmeissen.
      hilfreiche_karten = hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
      return hilfreiche_karten.sample(random: @zufalls_generator) unless hilfreiche_karten.empty?

      # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, macht man das.
      gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten)
      return gefaehrliche_karten.sample(random: @zufalls_generator) unless gefaehrliche_karten.empty?

      # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt.
      nicht_destruktive_karten = undestruktive_nicht_schlagende_karten(stich, waehlbare_karten)
      return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?
    end

    # Wenn der Sieger bleiben sollte, solange die Spieler danach vernünftig sind.
    sollte_bleiben = karte_sollte_bleiben?(stich, stich.staerkste_gespielte_karte)

    # Wenn möglich eine Auftragskarte rein schmeissen.
    if sollte_bleiben
      hilfreiche_karten = hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
      return hilfreiche_karten.sample(random: @zufalls_generator) unless hilfreiche_karten.empty?
    end

    # Wenn Spieler danach eine gute Chance haben, den Stich zu nehmen.
    nehmende_karten = nehmende_karten_danach(stich)

    # Wenn möglich eine Auftragskarte für einen späteren Spieler rein schmeissen.
    nehmende_karten.each do |nehmende_karte|
      hilfreiche_karten = hilfreiche_karten_fuer_nehmende_karte(stich, nehmende_karte, waehlbare_karten)
      return hilfreiche_karten.sample(random: @zufalls_generator) unless hilfreiche_karten.empty?
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, macht man das.
    if sollte_bleiben
      gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten)
      return gefaehrliche_karten.sample(random: @zufalls_generator) unless gefaehrliche_karten.empty?
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann unter der Annahme, dass ein späterer Spieler übernimmt, macht man das.
    nehmende_karten.each do |nehmende_karte|
      gefaehrliche_karten = gefaehrliche_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
      return gefaehrliche_karten.sample(random: @zufalls_generator) unless gefaehrliche_karten.empty?
    end

    # Wenn man selber einen Auftrag erfüllen könnte.
    selbst_helfende_karten = auftrags_nehmende_karten(waehlbare_karten, stich)
    return selbst_helfende_karten.sample(random: @zufalls_generator) unless selbst_helfende_karten.empty?

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt unter der Annahme, dass der Stich Sieger bleibt.
    if sollte_bleiben
      nicht_destruktive_karten = undestruktive_nicht_schlagende_karten(stich, waehlbare_karten)
      return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?
    end

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt unter der Annahme, dass ein späterer Spieler übernimmt.
    nehmende_karten.each do |nehmende_karte|
      nicht_destruktive_karten = undestruktive_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
      return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?
    end

    # Dann wenn möglich eine Karte werfen, die keine Auftragskarte ist.
    nicht_destruktive_karten = waehlbare_karten - alle_auftrags_karten
    return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?

    # Dann wenn möglich eine Karte werfen, die eine eigene Auftragskarte ist.
    nicht_andere_destruktive_karten = waehlbare_karten - auftrags_karten_anderer(0)
    return nicht_andere_destruktive_karten.sample(random: @zufalls_generator) unless nicht_andere_destruktive_karten.empty?

    waehlbare_karten.sample(random: @zufalls_generator)
  end

  def waehle_kommunikation(kommunizierbares)
    (kommunizierbares & gefaehrliche_hohe_unausweichliche_karten).sample(random: @zufalls_generator)
  end
end
