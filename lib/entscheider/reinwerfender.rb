# frozen_string_literal: true

require_relative 'gefaehrliche_karten_kommunizierender'

# Modul mit nützlichen Funktionen für den Reinwerfer, die aber auch teilweise vom Cowboy benutzt werden.
module Reinwerfender
  include GefaehrlicheKartenKommunizierender

  # Sagt ja, wenn der Stich bereits eine Auftragskarte des Siegers enthält.
  def toetlicher_bleibender_stich?(stich)
    # TODO: Wenn es klar ist, dass ein Nachfolger eine Auftragskarte des Siegers reinschmeissen muss,
    # ist es auch ein tötlicher Stich.
    !(stich.karten & auftrags_karten(stich.sieger_index)).empty?
  end

  # Gibt einen Spieler index zurück, der diesen Stich unbedingt nehmen muss,
  # wenn der Stich bereits eine Auftragskarte eines Spielers danach enthält
  # TODO: Wenn es klar ist, dass ein Nachfolger eine Auftragskarte reinschmeissen muss,
  # gibt es auch einen nehmen muesser sonst tot.
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

      gespielte_karte = Stich::GespielteKarte.new(karte: k, spieler_index: spieler_index)
      next unless karte_sollte_bleiben?(stich, gespielte_karte)

      gespielte_karte
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

  # Karten, die einen eigenen Auftrag erfüllen.
  def auftrags_nehmende_karten(waehlbare_karten, stich)
    # Eigene Auftragskarten
    gute_karten = auftrags_karten(0)

    # Kandidatenkarten, die den Stich nehmen könnten.
    kandidaten = waehlbare_karten.select do |k|
      k.schlaegt?(stich.staerkste_karte) &&
        karte_sollte_bleiben?(stich, Stich::GespielteKarte.new(karte: k, spieler_index: 0))
    end
    return [] if kandidaten.empty?

    # Kandidatenkarten, gleichzeitig Auftragskarten sind (beste Variante).
    gute_kandidaten = kandidaten & gute_karten
    return gute_kandidaten unless gute_kandidaten.empty?

    # Kandidaten, die einen Auftrag erfüllen, indem sie eine bisher im Stich vorhandene Karte holen
    return [] if (stich.karten & gute_karten).empty?

    kandidaten
  end
end
