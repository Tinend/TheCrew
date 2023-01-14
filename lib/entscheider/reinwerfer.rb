# coding: utf-8
# frozen_string_literal: true

require_relative 'zufalls_entscheider'
require_relative 'abspiel_anspiel_unterscheidender'
require_relative 'gefaehrliche_karten_kommunizierender'
require_relative '../entscheider'
require_relative '../stich'
require_relative '../farbe'
require_relative 'saeuger_auftrag_nehmer'
require_relative 'spiel_informations_sicht_benutzender'

# Entscheider, der immer zufällig entschiedet, was er spielt.
# Wenn er eine Karte reinwerfen kann, die jemand anderem hilft,
# tut er das.
class Reinwerfer < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include AbspielAnspielUnterscheidender
  include GefaehrlicheKartenKommunizierender

  # Sagt ja, wenn der Stich bereits eine Auftragskarte des Siegers enthält.
  def toetlicher_bleibender_stich?(stich)
    # TODO: Wenn es klar ist, dass ein Nachfolger eine Auftragskarte des Siegers reinschmeissen muss,
    # ist es auch ein tötlicher Stich.
    !(stich.karten & auftrags_karten(stich.sieger_index)).empty?
  end

  # Sagt ja, wenn der Stich bereits eine Auftragskarte eines Spielers danach enthält
  def nehmen_muesser_sonst_tot(stich)
    # Absichtlich sich selbst als letztes, da er lieber selber Aufträge vermasselt, als sie
    # für andere zu vermasseln.
    (spieler_indizes_danach(stich) + [0]).find do |spieler_index|
      !(stich.karten & auftrags_karten(spieler_index)).empty?
    end
  end

  def auftrags_karten_danach(stich)
    spieler_indizes_danach(stich).flat_map do |i|
      @spiel_informations_sicht.unerfuellte_auftraege[i].map(&:karte)
    end
  end

  def auftrags_karten(spieler_index)
    @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].map(&:karte)
  end

  def hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
    nicht_schlagende_karten(stich, waehlbare_karten) & auftrags_karten(stich.sieger_index)
  end

  def hilfreiche_karten_fuer_nehmende_karte(stich, nehmende_karte, waehlbare_karten)
    nehmbare_karten(stich, nehmende_karte, waehlbare_karten) & auftrags_karten(nehmende_karte.spieler_index)
  end

  def kann_sicher_spielen?(stich, spieler_index, karte)
    karte.farbe == stich.farbe || @spiel_informations_sicht.moegliche_karten(spieler_index).none? do |k|
      k.farbe == stich.farbe
    end
  end

  def nehmende_karten_fuer_spieler(stich, spieler_index)
    raise 'Die übernehm Logik funktioniert nicht für leere Stiche.' if stich.empty?

    @spiel_informations_sicht.sichere_karten(spieler_index).filter_map do |k|
      next unless k.schlaegt?(stich.staerkste_karte)
      next unless kann_sicher_spielen?(stich, spieler_index, k)

      Stich::GespielteKarte.new(karte: k, spieler_index: spieler_index)
    end
  end

  # Karten von Spielern danach, die den Stich nehmen könnten.
  def nehmende_karten_danach(stich)
    spieler_indizes_danach(stich).flat_map do |i|
      nehmende_karten_fuer_spieler(stich, i)
    end
  end

  # Karten, die man in diesem Stich rein werfen kann, die aber später für andere Aufträge gefährlich sein könnten.
  # TODO: Manchmal sind diese Karten eigentlich ungefährlich, wenn man sie schützen kann.
  # Das sollte man einprogrammieren.
  def gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten)
    nicht_schlagende_karten(stich, waehlbare_karten) & gefaehrliche_karten
  end

  # Karten, die man in diesem Stich rein werfen kann, die aber später für andere Aufträge gefährlich sein könnten.
  # TODO: Manchmal sind diese Karten eigentlich ungefährlich, wenn man sie schützen kann.
  # Das sollte man einprogrammieren.
  def gefaehrliche_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
    nehmbare_karten(stich, nehmende_karte, waehlbare_karten) & gefaehrliche_karten
  end

  # Karten, die den Stich nicht schlagen und auch nicht machen, dass wir sofort verlieren.
  def undestruktive_nicht_schlagende_karten(stich, waehlbare_karten)
    nicht_schlagende_karten(stich, waehlbare_karten) - alle_auftrags_karten
  end

  # Karten, die den Stich nicht schlagen und auch nicht machen, dass wir sofort verlieren.
  def undestruktive_nicht_schlagende_karten_wenn_bleibt(stich, waehlbare_karten)
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

  # Karten, die einen eigenen Auftrag erfüllen.
  def auftrags_nehmende_karten(waehlbare_karten, stich)
    # Eigene Auftragskarten
    gute_karten = auftrags_karten(0)

    # Kandidatenkarten, die den Stich nehmen könnten.
    kandidaten = waehlbare_karten.select do |k|
      k.schlaegt?(stich.staerkste_karte) & karte_sollte_bleiben?(stich,
                                                                 Stich::GespielteKarte.new(karte: k, spieler_index: 0))
    end
    return [] if kandidaten.empty?

    # Kandidatenkarten, gleichzeitig Auftragskarten sind (beste Variante).
    gute_kandidaten = kandidaten & gute_karten
    return gute_kandidaten unless gute_kandidaten.empty?

    # Kandidaten, die einen Auftrag erfüllen, indem sie eine bisher im Stich vorhandene Karte holen
    return [] if (stich.karten & gute_karten).empty?

    kandidaten
  end

  def anspielen(waehlbare_karten)
    waehlbare_karten.sample(random: @zufalls_generator)
  end

  def toetlichen_bleibenden_stich_abspielen(stich, waehlbare_karten)
    # Wenn möglich eine Auftragskarte rein schmeissen.
    hilfreiche_karten = hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
    return hilfreiche_karten.sample(random: @zufalls_generator) unless hilfreiche_karten.empty?

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, macht man das.
    gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten)
    return gefaehrliche_karten.sample(random: @zufalls_generator) unless gefaehrliche_karten.empty?

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt.
    nicht_destruktive_karten = undestruktive_nicht_schlagende_karten_wenn_bleibt(stich, waehlbare_karten)
    return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?

    # Ansonsten haben wir eh verloren und nehmen eine zufällige Karte.
    waehlbare_karten.sample(random: @zufalls_generator)
  end

  def truempfe(karten)
    karten.select { |k| k.farbe == Farbe::RAKETE }
  end

  def nicht_truempfe(karten)
    karten.reject { |k| k.farbe == Farbe::RAKETE }
  end

  def max_karte(karten)
    trumpfs = truempfe(karten)
    return trumpfs.max_by(&:wert) unless trumpfs.empty?

    max_wert = karten.map(&:wert).max
    karten.select { |k| k.wert == max_wert }.sample(random: @zufalls_generator)
  end

  def min_karte(karten)
    nicht_trumpfs = nicht_truempfe(karten)
    return karten.max_by(&:wert) if nicht_trumpfs.empty?

    min_wert = nicht_trumpfs.map(&:wert).min
    nicht_trumpfs.select { |k| k.wert == min_wert }.sample(random: @zufalls_generator)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  def toetlichen_genommenen_stich_abspielen(stich, nehmen_muesser, waehlbare_karten)
    # Wenn wir selbst nehmen müssen, machen wir das.
    if nehmen_muesser.zero?
      # Wenn wir eine gute Option haben, machen wir das.
      gute_karten = auftrags_nehmende_karten(waehlbare_karten, stich)
      return max_karte(gute_karten) unless gute_karten.empty?

      # Ansonsten versuchen wir, was wir können.
      return max_karte(waehlbare_karten)
    end

    # Wenn wir wissen, dass er bestimmte Auftragskarte nehmen kann,
    # eine möglichst hohe nehmbare Auftragskarte rein schmeissen.
    nehmende_karten = nehmende_karten_fuer_spieler(stich, nehmen_muesser)
    nehmende_karten.each do |nehmende_karte|
      hilfreiche_karten = hilfreiche_karten_fuer_nehmende_karte(stich, nehmende_karte, waehlbare_karten)
      return max_karte(hilfreiche_karten) unless hilfreiche_karten.empty?
    end

    # Wenn möglich eine möglichst tiefe Auftragskarte rein schmeissen.
    hilfreiche_karten = auftrags_karten(nehmen_muesser) & waehlbare_karten
    return min_karte(hilfreiche_karten) unless hilfreiche_karten.empty?

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, die sicher übernommen werden können,
    # macht man das.
    nehmende_karten.each do |nehmende_karte|
      gefaehrliche_karten = gefaehrliche_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
      return max_karte(gefaehrliche_karten) unless gefaehrliche_karten.empty?
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, die nicht schlagen, macht man das.
    gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten)
    return max_karte(gefaehrliche_karten) unless gefaehrliche_karten.empty?

    # Dann eine möglichst tiefe Karte legen, die keinen anderen Auftrag zerstört.
    nicht_destruktive_karten = waehlbare_karten - auftrags_karten_anderer(nehmen_muesser)
    return min_karte(nicht_destruktive_karten) unless nicht_destruktive_karten.empty?

    # Dann ist eh egal. Wir nehmen eine möglichst tiefe.
    min_karte(waehlbare_karten)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  def abspielen(stich, waehlbare_karten)
    # Wenn dieser Stich eh schon tötlich ist, wenn er nicht durchkommt.
    return toetlichen_bleibenden_stich_abspielen(stich, waehlbare_karten) if toetlicher_bleibender_stich?(stich)

    # Wenn dieser Stich eh schon tötlich ist, wenn er nicht bei einer bestimmten Person landet.
    nehmen_muesser = nehmen_muesser_sonst_tot(stich)
    return toetlichen_genommenen_stich_abspielen(stich, nehmen_muesser, waehlbare_karten) if nehmen_muesser

    # Wenn der Sieger bleiben sollte, solange die Spieler danach vernünftig sind.
    sollte_bleiben = karte_sollte_bleiben?(stich, stich.staerkste_gespielte_karte)

    # Wenn möglich eine Auftragskarte rein schmeissen.
    if sollte_bleiben
      hilfreiche_karten = hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
      return max_karte(hilfreiche_karten) unless hilfreiche_karten.empty?
    end

    # Wenn Spieler danach eine gute Chance haben, den Stich zu nehmen.
    nehmende_karten = nehmende_karten_danach(stich)

    # Wenn möglich eine Auftragskarte für einen späteren Spieler rein schmeissen.
    nehmende_karten.each do |nehmende_karte|
      hilfreiche_karten = hilfreiche_karten_fuer_nehmende_karte(stich, nehmende_karte, waehlbare_karten)
      return max_karte(hilfreiche_karten) unless hilfreiche_karten.empty?
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, macht man das.
    if sollte_bleiben
      gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten)
      return max_karte(gefaehrliche_karten) unless gefaehrliche_karten.empty?
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann unter der Annahme,
    # dass ein späterer Spieler übernimmt, macht man das.
    nehmende_karten.each do |nehmende_karte|
      gefaehrliche_karten = gefaehrliche_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
      return max_karte(gefaehrliche_karten) unless gefaehrliche_karten.empty?
    end

    # Wenn man selber einen Auftrag erfüllen könnte.
    selbst_helfende_karten = auftrags_nehmende_karten(waehlbare_karten, stich)
    return max_karte(selbst_helfende_karten) unless selbst_helfende_karten.empty?

    kleinstes_uebel(stich, waehlbare_karten, nehmende_karten, sollte_bleiben)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength

  # Wenn es ziemlich schlecht aussieht, versucht diese Funktion, irgendwie zu verhindern, dass wir sofort verlieren.
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def kleinstes_uebel(stich, waehlbare_karten, nehmende_karten, sollte_bleiben)
    # Dann wenn möglich eine Karte werfen, die keine Auftragskarte ist und auch nicht schlägt.
    nicht_destruktive_karten = undestruktive_nicht_schlagende_karten(stich, waehlbare_karten)
    return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt
    # unter der vertretbaren Annahme, dass der Stich Sieger bleibt.
    if sollte_bleiben
      nicht_destruktive_karten = undestruktive_nicht_schlagende_karten_wenn_bleibt(stich, waehlbare_karten)
      return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?
    end

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt unter der Annahme,
    # dass ein späterer Spieler übernimmt.
    nehmende_karten.each do |nehmende_karte|
      nicht_destruktive_karten = undestruktive_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
      return nicht_destruktive_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?
    end

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt
    # unter der unklaren Annahme, dass der Stich Sieger bleibt.
    hoffnungsvoll_bleibende_karten = undestruktive_nicht_schlagende_karten_wenn_bleibt(stich, waehlbare_karten)
    return hoffnungsvoll_bleibende_karten.sample(random: @zufalls_generator) unless nicht_destruktive_karten.empty?

    # Dann wenn möglich eine Karte werfen, die eine Auftragskarte eines Spielers danach ist.
    hoffnungsvoll_geschlagene_karten = auftrags_karten_danach(stich)
    min_karte(hoffnungsvoll_geschlagene_karten) unless hoffnungsvoll_geschlagene_karten.empty?

    # Wenn dieser Punkt erreicht wird, haben wir eh schon verloren. Es ist eigentlich egal, was wir hier machen.

    # Dann wenn möglich eine Karte werfen, die eine eigene Auftragskarte ist.
    # Der Reinwerfer vermasselt es sich lieber selbst als anderen.
    nicht_andere_destruktive_karten = waehlbare_karten - auftrags_karten_anderer(0)
    unless nicht_andere_destruktive_karten.empty?
      return nicht_andere_destruktive_karten.sample(random: @zufalls_generator)
    end

    waehlbare_karten.sample(random: @zufalls_generator)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def waehle_kommunikation(kommunizierbares)
    (kommunizierbares & gefaehrliche_hohe_unausweichliche_karten).sample(random: @zufalls_generator)
  end
end
