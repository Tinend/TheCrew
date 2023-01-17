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
  end

  def anzahl_karten
    @spiel_informations_sicht.anzahl_karten(spieler_index: @spieler_index)
  end
  
  def berechne_karten_wkeiten
    @karten_wkeiten = Hash.new
    Karte.alle.each do |karte|
      @karten_wkeiten[karte] = 0
    end
    @sichere_karten.each do |karte|
      @karten_wkeiten[karte] = 1
    end
    moegliche_wkeit = (anzahl_karten - @sichere_karten.length).to_f / @strikt_moegliche_karten.length
    @strikt_moegliche_karten.each do |karte|
      @karten_wkeiten[karte] = moegliche_wkeit
    end
    karten_wkeiten_normieren
    print "#{@spieler_index}:   "
    @karten_wkeiten.each do |kw|
      print "#{kw[0]} #{(kw[1] * 100 + 0.5).to_i} "
    end
    puts
  end

  def karten_wkeiten_normieren # funktioniert noch nicht
    summe = @karten_wkeiten.reduce(0.0) {|summe_zwischen_ergebnis, karten_wkeit|
      if karten_wkeit == 1
        0
      else
        summe_zwischen_ergebnis + karten_wkeit[1]
      end
    }
    @karten_wkeiten.each do |element|
      if element[1] != 1
        element[1] /=  summe * anzahl_karten
      end
    end
  end

  def min_auftraege_lege_wkeit(spieler_index:, karte:)
    wkeit = 0
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    moegliche_auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].dup
    moegliche_auftraege.select! do |auftrag|
      @moegliche_karten.any? { |moegliche_karte| moegliche_karte == auftrag.karte }
    end
    moegliche_auftraege.each do |auftrag|
      auftrag_wkeit = min_wkeit_auftrag_legen(spieler_index: spieler_index, farbe: farbe, auftrag: auftrag)
      wkeit = 1 - ((1 - wkeit) * (1 - auftrag_wkeit))
    end
    wkeit
  end

  def max_auftraege_lege_wkeit(spieler_index:, karte:)
    wkeit = 0
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    moegliche_auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].dup
    moegliche_auftraege.select! do |auftrag|
      @moegliche_karten.any? { |moegliche_karte| moegliche_karte == auftrag.karte }
    end
    moegliche_auftraege.each do |auftrag|
      auftrag_wkeit = max_wkeit_auftrag_legen(spieler_index: spieler_index, farbe: farbe, auftrag: auftrag)
      wkeit = 1 - ((1 - wkeit) * (1 - auftrag_wkeit))
    end
    wkeit
  end

  def min_wkeit_auftrag_legen(spieler_index:, farbe:, auftrag:)
    hat_auftrag_sicher = @sichere_karten.any? { |karte| karte == auftrag.karte }
    if auftrag.farbe == farbe && hat_auftrag_sicher
      0.75**(@moegliche_karten.select { |karte| karte.farbe == auftrag.farbe }.length - 1)
    elsif auftrag.farbe == farbe
      (0.75**(@moegliche_karten.select { |karte| karte.farbe == auftrag.farbe }.length - 1)) * 0.25
    else
      0
    end
  end

  def max_wkeit_auftrag_legen(spieler_index:, farbe:, auftrag:)
    hat_auftrag_sicher = @sichere_karten.any? { |karte| karte == auftrag.karte }
    hat_karte_wert = 0.75**@moegliche_karten.select { |karte| karte.farbe == auftrag.farbe }.length
    if auftrag.farbe == farbe && hat_auftrag_sicher
      1
    elsif auftrag.farbe == farbe
      0.25
    elsif hat_auftrag_sicher
      hat_karte_wert
    else
      0.25 * hat_karte_wert
    end
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
