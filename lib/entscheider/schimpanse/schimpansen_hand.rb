# coding: utf-8
# frozen_string_literal: true

# verwaltet die erwartete Hand eines beliebigen Spielers für den Schimpansen
class SchimpansenHand
  def initialize(stich:, spiel_informations_sicht:, spieler_index:)
    @spieler_index = spieler_index
    @spiel_informations_sicht = spiel_informations_sicht
    @stich = stich
    @moegliche_karten = @spiel_informations_sicht.moegliche_karten(spieler_index).dup
    @sichere_karten = @spiel_informations_sicht.sichere_karten(spieler_index).dup
    @strikt_moegliche_karten = @moegliche_karten - @sichere_karten
    berechne_karten_wkeiten
    erzeuge_blank_wkeiten
  end

  def erzeuge_blank_wkeiten
    @blank_wkeiten = {}
    Farbe::FARBEN.each do |farbe|
      @blank_wkeiten[farbe] = Karte.alle_mit_farbe(farbe).reduce(1) do |wkeit, karte|
        wkeit * (1 - @karten_wkeiten[karte])
      end
    end
  end
  
  def anzahl_karten
    @spiel_informations_sicht.anzahl_karten(spieler_index: @spieler_index)
  end

  def berechne_karten_wkeiten
    @karten_wkeiten = {}
    Karte.alle.each do |karte|
      @karten_wkeiten[karte] = 0
    end
    @sichere_karten.each do |karte|
      @karten_wkeiten[karte] = 1
    end
    if @strikt_moegliche_karten.empty?
      moegliche_wkeit = 0
    else
      moegliche_wkeit = (anzahl_karten - @sichere_karten.length).to_f / @strikt_moegliche_karten.length
    end
    @strikt_moegliche_karten.each do |karte|
      @karten_wkeiten[karte] = moegliche_wkeit
    end
    # p [moegliche_wkeit, anzahl_karten]
    # print "#{@spieler_index}:   "
    # @karten_wkeiten.each do |kw|
    # print "#{kw[0]} #{(kw[1] * 100 + 0.5).to_i} "
    # end
    # puts
    karten_wkeiten_normieren
  end

  def karten_wkeiten_normieren
    anzahl_strikt_moegliche_karten = anzahl_karten
    summe = @karten_wkeiten.reduce(0.0) do |summe_zwischen_ergebnis, karten_wkeit|
      if karten_wkeit[1] == 1
        anzahl_strikt_moegliche_karten -= 1
        summe_zwischen_ergebnis
      else
        summe_zwischen_ergebnis + karten_wkeit[1]
      end
    end
    @karten_wkeiten.each do |element|
      element[1] /= summe * anzahl_strikt_moegliche_karten if element[1] != 1
    end
  end

  def blank_min_auftraege_legen_wkeit(spieler_index:, karte:, farbe:)
    @blank_wkeiten[farbe] * @karten_wkeiten.reduce(1) {|wkeit, karten_wkeit|
      if karten_wkeit[0].farbe != farbe || @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? {|auftrag| auftrag.karte == karten_wkeit[0]}
        wkeit
      else
        wkeit * karten_wkeit[1]
      end
    }
  end

  def unblank_min_auftraege_legen_wkeit(spieler_index:, karte:, farbe:)
    (1 - @blank_wkeiten[farbe]) * @karten_wkeiten.reduce(1) {|wkeit, karten_wkeit|
      if karten_wkeit[0].farbe == farbe || @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? {|auftrag| auftrag.karte == karten_wkeit[0]}
        wkeit
      else
        wkeit * karten_wkeit[1]
      end
    }
  end

  def min_auftraege_lege_wkeit(spieler_index:, karte:)
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    wkeit = blank_min_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit += unblank_min_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit
  end

  def blank_max_auftraege_legen_wkeit(spieler_index:, karte:, farbe:)
    @blank_wkeiten[farbe] * @karten_wkeiten.reduce(0) {|wkeit, karten_wkeit|
      if karten_wkeit[0].farbe == farbe && @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? {|auftrag| auftrag.karte == karten_wkeit[0]}
        1 - (1 - wkeit) * (1 - karten_wkeit[1])
      else
        wkeit
      end
    }
  end

  def unblank_max_auftraege_legen_wkeit(spieler_index:, karte:, farbe:)
    (1 - @blank_wkeiten[farbe]) * @karten_wkeiten.reduce(1) {|wkeit, karten_wkeit|
      if karten_wkeit[0].farbe != farbe && @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? {|auftrag| auftrag.karte == karten_wkeit[0]}
        1 - (1 - wkeit) * (1 - karten_wkeit[1])
      else
        wkeit
      end
    }
  end

  def max_auftraege_lege_wkeit(spieler_index:, karte:)
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    wkeit = blank_max_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit += unblank_max_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit
  end

  def min_schlag_wert(schlag_wert:, staerkste_karte:)
    return 0 if schlag_wert <= staerkste_karte.schlag_wert
    kleiner_wkeit = 0
    gleich_wkeit = 0
    @karten_wkeiten.each do |karten_wkeit|
      if karten_wkeit[0].farbe == staerkste_karte.farbe && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1]
      elsif karten_wkeit[0].trumpf? && !staerkste_karte.trumpf? && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1] * @blank_wkeiten[staerkste_karte.farbe]
      elsif schlag_wert > karten_wkeit[0].schlag_wert && karten_wkeit[0].farbe == staerkste_karte.farbe
        kleiner_wkeit = 1 - (1 - kleiner_wkeit) * (1 - karten_wkeit[1])
      elsif schlag_wert > karten_wkeit[0].schlag_wert && karten_wkeit[0].trumpf? && !staerkste_karte.trumpf?
        kleiner_wkeit = 1 - (1 - kleiner_wkeit) * (1 - karten_wkeit[1] * @blank_wkeiten[staerkste_karte.farbe])
      end
    end
    (1 - kleiner_wkeit) * gleich_wkeit
  end

  def max_schlag_wert(schlag_wert:, staerkste_karte:)
    return 0 if schlag_wert <= staerkste_karte.schlag_wert
    groesser_wkeit = 0
    gleich_wkeit = 1
    @karten_wkeiten.each do |karten_wkeit|
      if karten_wkeit[0].farbe == staerkste_karte.farbe && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1]
      elsif karten_wkeit[0].trumpf? && !staerkste_karte.trumpf? && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1] * @blank_wkeiten[staerkste_karte.farbe]
      elsif schlag_wert < karten_wkeit[0].schlag_wert && karten_wkeit[0].farbe == staerkste_karte
        groesser_wkeit = 1 - (1 - groesser_wkeit) * (1 - karten_wkeit[1])
      elsif schlag_wert < karten_wkeit[0].schlag_wert && karten_wkeit[0].trumpf? && !staerkste_karte.trumpf?
        groesser_wkeit = 1 - (1 - groesser_wkeit) * (1 - karten_wkeit[1] * @blank_wkeiten[staerkste_karte.farbe])
      end
    end
    (1 - groesser_wkeit) * gleich_wkeit
  end

  def gespielt?
    @spieler_index.zero? or @spieler_index + @stich.karten.length >= @spiel_informations_sicht.anzahl_spieler
  end

  def min_sieges_wkeit(staerkste_karte)
    return 0 if gespielt?
    return 0 if @sichere_karten.any? do |karte|
                  !karte.schlaegt?(staerkste_karte) && staerkste_karte.farbe == karte.farbe
                end

    moegliche_tiefere_karten = @strikt_moegliche_karten.select do |karte|
      !karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe
    end
    (1 - (1 - (0.75**moegliche_tiefere_karten.length))) * kann_hoeher_wkeit(staerkste_karte)
  end

  def kann_hoeher_wkeit(staerkste_karte)
    if @sichere_karten.any? { |karte| karte.farbe == staerkste_karte.farbe && karte.schlaegt?(staerkste_karte) }
      1
    else
      moegliche_hoehere_karten = @strikt_moegliche_karten.select do |karte|
        karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe
      end
      1 - (0.75**moegliche_hoehere_karten.length)
    end
  end

  def sicherer_sieg_gegen_staerkste_karte?(staerkste_karte)
    (@moegliche_karten.all? { |karte| karte.farbe != staerkste_karte.farbe } &&
     @sichere_karten.any? { |karte| karte.schlaegt?(staerkste_karte) })
  end

  def max_sieges_wkeit(staerkste_karte)
    return 0 if gespielt?
    return 1 if @sichere_karten.any? do |karte|
                  karte.schlaegt?(staerkste_karte) && staerkste_karte.farbe == karte.farbe
                end

    if sicherer_sieg_gegen_staerkste_karte?(staerkste_karte)
      1
    else
      moegliche_hoehere_karten = berechne_schlagende_karten(staerkste_karte)
      (1 - (0.75**moegliche_hoehere_karten.length))
    end
  end

  def berechne_schlagende_karten(staerkste_karte)
    @moegliche_karten.select do |karte|
      karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe
    end
  end
end
