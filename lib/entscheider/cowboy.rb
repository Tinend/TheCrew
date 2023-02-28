# coding: utf-8
# frozen_string_literal: true

require_relative 'reinwerfender'
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
# rubocop:disable Metrics/ClassLength
class Cowboy < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include AbspielAnspielUnterscheidender
  include GefaehrlicheKartenKommunizierender
  include Reinwerfender

  # Karten, die eim eigenen Auftrag helfen könnten.
  def eigennuetzige_karten
    karten.select do |karte|
      !alle_auftrags_karten.include?(karte) && auftrags_karten(0).any? do |k|
        karte.schlaegt?(k) || karte.farbe == k.farbe
      end
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
    nehmbare_karten(stich, nehmende_karte, waehlbare_karten) & (gefaehrliche_karten - eigennuetzige_karten)
  end

  def durchbringbare_auftrags_karten(waehlbare_karten)
    schlechte_farben = blanke_auftrags_farben_anderer
    (waehlbare_karten & auftrags_karten(0)).select do |k|
      karte_sollte_bleiben?(Stich.new, Stich::GespielteKarte.new(karte: k, spieler_index: 0)) &&
        !schlechte_farben.include?(k.farbe)
    end
  end

  def auftrag_fordernde_karten(waehlbare_karten)
    auftrags_forderungs_farben = (auftrags_karten(0) - karten).map(&:farbe).uniq
    (waehlbare_karten - alle_auftrags_karten).select do |k|
      karte_sollte_bleiben?(Stich.new, Stich::GespielteKarte.new(karte: k, spieler_index: 0)) &&
        auftrags_forderungs_farben.any? { |f| k.farbe == f } &&
        !blanke_auftrags_farben_anderer.include?(k.farbe)
    end
  end

  def blanke_auftrags_farben
    Farbe::NORMALE_FARBEN.select do |farbe|
      andere_spieler_indizes(0).any? do |i|
        moegliche_karten_der_farbe = @spiel_informations_sicht.moegliche_karten(i).select do |k|
          k.farbe == farbe
        end
        # Wenn der Spieler mindestens eine Karte der Farbe hat und
        # alle Karten der Farbe Auftragskarten sind, ist die Farbe gefährlich
        !moegliche_karten_der_farbe.empty? && (moegliche_karten_der_farbe - alle_auftrags_karten).empty?
      end
    end
  end

  def blanke_auftrags_farben_anderer
    Farbe::NORMALE_FARBEN.select do |farbe|
      andere_spieler_indizes(0).any? do |i|
        moegliche_karten_der_farbe = @spiel_informations_sicht.moegliche_karten(i).select do |k|
          k.farbe == farbe
        end
        # Wenn der Spieler mindestens eine Karte der Farbe hat und
        # alle Karten der Farbe Auftragskarten sind, ist die Farbe gefährlich
        !moegliche_karten_der_farbe.empty? && (moegliche_karten_der_farbe - auftrags_karten_anderer(0)).empty?
      end
    end
  end

  # Karten, die eine Farbe weg ziehen, wo man selber eine Auftragskarte durch bringen will.
  def farbe_ziehende_karten(waehlbare_karten)
    zieh_farben = (auftrags_karten(0) & karten).map(&:farbe).uniq - blanke_auftrags_farben
    (waehlbare_karten - alle_auftrags_karten).select do |k|
      zieh_farben.any? { |f| k.farbe == f }
    end
  end

  # Karten, die Aufträge oder gefährliche Karten ziehen und selber eine harmlose Farbe haben.
  def alles_ziehende_karten(waehlbare_karten)
    verbotene_farben = alle_auftrags_karten.map(&:farbe).uniq
    (waehlbare_karten - alle_auftrags_karten).select do |k|
      verbotene_farben.none? { |f| k.farbe == f }
    end
  end

  def anspielen(waehlbare_karten)
    auftrags_karten(0).empty? ? altruistisch_anspielen(waehlbare_karten) : egoistisch_anspielen(waehlbare_karten)
  end

  # rubocop:disable Metrics/MethodLength
  def egoistisch_anspielen(waehlbare_karten)
    @zaehler_manager.erhoehe_zaehler(:egositisch_anspielen)

    # TODO: Wissentlich Aufträge zerstören verhindern.
    durchbringbare = durchbringbare_auftrags_karten(waehlbare_karten)
    unless durchbringbare.empty?
      @zaehler_manager.erhoehe_zaehler(:durchbringbare)
      durchbringbare.sample(random: @zufalls_generator)
    end

    fordernde = auftrag_fordernde_karten(waehlbare_karten)
    unless fordernde.empty?
      @zaehler_manager.erhoehe_zaehler(:fordernde)
      return max_karte(fordernde)
    end

    farb_ziehende = farbe_ziehende_karten(waehlbare_karten)
    unless farb_ziehende.empty?
      @zaehler_manager.erhoehe_zaehler(:farb_ziehende)
      return max_karte(farb_ziehende)
    end

    alles_ziehende = alles_ziehende_karten(waehlbare_karten)
    unless alles_ziehende.empty?
      @zaehler_manager.erhoehe_zaehler(:alles_ziehende)
      max_karte(alles_ziehende)
    end

    altruistisch_anspielen(waehlbare_karten)
  end
  # rubocop:enable Metrics/MethodLength

  def hilfreich_angespielte_auftrags_karten(waehlbare_karten)
    (waehlbare_karten & auftrags_karten_anderer(0)).select do |karte|
      hypothethischer_stich = Stich.new
      hypothethischer_stich.legen(karte: karte, spieler_index: 0)
      (1...anzahl_spieler).any? do |spieler_index|
        !nehmende_karten_fuer_spieler(hypothethischer_stich, spieler_index).empty?
      end
    end
  end

  def altruistisch_anspielen(waehlbare_karten)
    @zaehler_manager.erhoehe_zaehler(:altruistisch_anspielen)

    hilfreiche_karten = hilfreich_angespielte_auftrags_karten(waehlbare_karten)
    hilfreiche_karten.sample(random: @zufalls_generator) unless hilfreiche_karten.empty?

    egal_karten = (waehlbare_karten - alle_auftrags_karten)
    min_karte(egal_karten) unless egal_karten.empty?

    # TODO: Zuerst sicher tote Aufträge beachten.
    nicht_meine_auftraege = (waehlbare_karten - auftrags_karten(0))
    min_karte(nicht_meine_auftraege) unless nicht_meine_auftraege.empty?

    max_karte(waehlbare_karten)
  end

  def toetlichen_bleibenden_stich_abspielen(stich, waehlbare_karten)
    @zaehler_manager.erhoehe_zaehler(:toetlichen_bleibenden_stich_abspielen)

    # Wenn möglich eine Auftragskarte rein schmeissen.
    hilfreiche_karten = hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
    return hilfreiche_karten.sample(random: @zufalls_generator) unless hilfreiche_karten.empty?

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, macht man das.
    gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten) - eigennuetzige_karten
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
    return karten.min_by(&:wert) if nicht_trumpfs.empty?

    min_wert = nicht_trumpfs.map(&:wert).min
    nicht_trumpfs.select { |k| k.wert == min_wert }.sample(random: @zufalls_generator)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def toetlichen_genommenen_stich_abspielen(stich, nehmen_muesser, waehlbare_karten)
    @zaehler_manager.erhoehe_zaehler(:toetlichen_genommenen_stich_abspielen)

    # Wenn wir selbst nehmen müssen, machen wir das.
    if nehmen_muesser.zero?
      # Wenn wir eine gute Option haben, machen wir das.
      gute_karten = auftrags_nehmende_karten(waehlbare_karten, stich)
      unless gute_karten.empty?
        @zaehler_manager.erhoehe_zaehler(:selber_nehmen_muesser_gut)
        return max_karte(gute_karten)
      end

      # Ansonsten versuchen wir, was wir können.
      @zaehler_manager.erhoehe_zaehler(:selber_nehmen_muesser_schlecht)
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
      gefaehrliche_karten = gefaehrliche_nehmbare_karten(stich, nehmende_karte, waehlbare_karten) - eigennuetzige_karten
      return max_karte(gefaehrliche_karten) unless gefaehrliche_karten.empty?
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, die nicht schlagen, macht man das.
    gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten) - eigennuetzige_karten
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
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def abspielen(stich, waehlbare_karten)
    @zaehler_manager.erhoehe_zaehler(:abspielen)

    # Wenn dieser Stich eh schon tötlich ist, wenn er nicht durchkommt.
    return toetlichen_bleibenden_stich_abspielen(stich, waehlbare_karten) if toetlicher_bleibender_stich?(stich)

    # Wenn dieser Stich eh schon tötlich ist, wenn er nicht bei einer bestimmten Person landet.
    nehmen_muesser = nehmen_muesser_sonst_tot(stich)
    if nehmen_muesser
      @zaehler_manager.erhoehe_zaehler(:nehmen_muesser)
      return toetlichen_genommenen_stich_abspielen(stich, nehmen_muesser, waehlbare_karten)
    end

    # Wenn man selber einen Auftrag erfüllen könnte.
    selbst_helfende_karten = auftrags_nehmende_karten(waehlbare_karten, stich)
    @zaehler_manager.erhoehe_zaehler(:selbst_helfende_karten)
    return max_karte(selbst_helfende_karten) unless selbst_helfende_karten.empty?

    # Wenn der Sieger bleiben sollte, solange die Spieler danach vernünftig sind.
    sollte_bleiben = karte_sollte_bleiben?(stich, stich.staerkste_gespielte_karte)

    # Wenn möglich eine Auftragskarte rein schmeissen.
    if sollte_bleiben
      hilfreiche_karten = hilfreiche_karten_fuer_gespielte_karte(stich, waehlbare_karten)
      unless hilfreiche_karten.empty?
        @zaehler_manager.erhoehe_zaehler(:sollte_bleiben_hilfreiche_karten)
        return max_karte(hilfreiche_karten)
      end
    end

    # Wenn Spieler danach eine gute Chance haben, den Stich zu nehmen.
    nehmende_karten = nehmende_karten_danach(stich)

    # Wenn möglich eine Auftragskarte für einen späteren Spieler rein schmeissen.
    nehmende_karten.each do |nehmende_karte|
      hilfreiche_karten = hilfreiche_karten_fuer_nehmende_karte(stich, nehmende_karte, waehlbare_karten)
      unless hilfreiche_karten.empty?
        @zaehler_manager.erhoehe_zaehler(:nehmende_karten_hilfreiche_karten)
        return max_karte(hilfreiche_karten)
      end
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann, macht man das.
    if sollte_bleiben
      gefaehrliche_karten = gefaehrliche_nicht_schlagende_karten(stich, waehlbare_karten) - eigennuetzige_karten
      unless gefaehrliche_karten.empty?
        @zaehler_manager.erhoehe_zaehler(:sollte_bleiben_gefaehrliche_karten)
        return max_karte(gefaehrliche_karten) unless gefaehrliche_karten.empty?
      end
    end

    # Wenn man gefährliche Karten für andere Aufträge wegwerfen kann unter der Annahme,
    # dass ein späterer Spieler übernimmt, macht man das.
    nehmende_karten.each do |nehmende_karte|
      gefaehrliche_karten = gefaehrliche_nehmbare_karten(stich, nehmende_karte, waehlbare_karten) - eigennuetzige_karten
      unless gefaehrliche_karten.empty?
        @zaehler_manager.erhoehe_zaehler(:nehmende_karten_gefaehrliche_karten)
        return max_karte(gefaehrliche_karten) unless gefaehrliche_karten.empty?
      end
    end

    kleinstes_uebel(stich, waehlbare_karten, nehmende_karten, sollte_bleiben)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # Wenn es ziemlich schlecht aussieht, versucht diese Funktion, irgendwie zu verhindern, dass wir sofort verlieren.
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize
  def kleinstes_uebel(stich, waehlbare_karten, nehmende_karten, sollte_bleiben)
    @zaehler_manager.erhoehe_zaehler(:kleinstes_uebel)

    # Dann wenn möglich eine Karte werfen, die keine Auftragskarte ist und auch nicht schlägt.
    nicht_destruktive_karten = undestruktive_nicht_schlagende_karten(stich, waehlbare_karten)
    unless nicht_destruktive_karten.empty?
      @zaehler_manager.erhoehe_zaehler(:nicht_destruktive_nicht_schlagende_karten)
      return nicht_destruktive_karten.sample(random: @zufalls_generator)
    end

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt
    # unter der vertretbaren Annahme, dass der Stich Sieger bleibt.
    if sollte_bleiben
      nicht_destruktive_karten = undestruktive_nicht_schlagende_karten_wenn_bleibt(stich, waehlbare_karten)
      unless nicht_destruktive_karten.empty?
        @zaehler_manager.erhoehe_zaehler(:sollte_bleiben_nicht_destruktive_karten)
        return nicht_destruktive_karten.sample(random: @zufalls_generator)
      end
    end

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt unter der Annahme,
    # dass ein späterer Spieler übernimmt.
    nehmende_karten.each do |nehmende_karte|
      nicht_destruktive_karten = undestruktive_nehmbare_karten(stich, nehmende_karte, waehlbare_karten)
      unless nicht_destruktive_karten.empty?
        @zaehler_manager.erhoehe_zaehler(:nehmende_karten_nicht_destruktive_karten)
        return nicht_destruktive_karten.sample(random: @zufalls_generator)
      end
    end

    # Dann wenn möglich eine Karte werfen, die keine Auftragskarte ist.
    nicht_destruktive_karten = waehlbare_karten - alle_auftrags_karten
    unless nicht_destruktive_karten.empty?
      @zaehler_manager.erhoehe_zaehler(:nicht_destruktive_karten)
      return nicht_destruktive_karten.sample(random: @zufalls_generator)
    end

    # Dann wenn möglich eine Karte werfen, die uns nicht sofort verlieren lässt
    # unter der unklaren Annahme, dass der Stich Sieger bleibt.
    hoffnungsvoll_bleibende_karten = undestruktive_nicht_schlagende_karten_wenn_bleibt(stich, waehlbare_karten)
    unless hoffnungsvoll_bleibende_karten.empty?
      @zaehler_manager.erhoehe_zaehler(:hoffnungsvoll_bleibende_karten)
      return hoffnungsvoll_bleibende_karten.sample(random: @zufalls_generator)
    end

    # Dann wenn möglich eine Karte werfen, die eine Auftragskarte von einem selbst oder
    # eines Spielers danach ist.
    hoffnungsvoll_geschlagene_karten = auftrags_karten_danach(stich) + auftrags_karten(0)
    unless hoffnungsvoll_geschlagene_karten.empty?
      @zaehler_manager.erhoehe_zaehler(:hoffnungsvoll_geschlagene_karten)
      min_karte(hoffnungsvoll_geschlagene_karten)
    end

    # Wenn dieser Punkt erreicht wird, haben wir eh schon verloren. Es ist eigentlich egal, was wir hier machen.
    @zaehler_manager.erhoehe_zaehler(:schon_verloren)
    waehlbare_karten.sample(random: @zufalls_generator)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize
end
# rubocop:enable Metrics/ClassLength
