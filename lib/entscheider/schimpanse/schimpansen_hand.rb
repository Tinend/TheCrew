# coding: utf-8
# verwaltet die erwartete Hand eines beliebigen Spielers für den Schimpansen
class SchimpansenHand
  def initialize(stich:, spiel_informations_sicht:, spieler_index:)
    @spieler_index = spieler_index
    @spiel_informations_sicht = spiel_informations_sicht
    @stich = stich
    @moegliche_karten = @spiel_informations_sicht.moegliche_karten(spieler_index).dup
    @sichere_karten = @spiel_informations_sicht.sichere_karten(spieler_index).dup
    @strikt_moegliche_karten = @moegliche_karten - @sichere_karten
    kommunikation_verwenden
  end

  def kommunikation_verwenden
    return if @spieler_index == 0
    Farbe::NORMALE_FARBEN.each do |farbe|
      kommunkikation_mit_farbe_verwenden(farbe)
    end
  end

  def kommunkikation_mit_farbe_verwenden(farbe)
    return if @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe).empty?
    nicht_kommuniziert_verwenden(farbe) if @spiel_informations_sicht.kommunikationen[@spieler_index].nil?
    kommuniziert_verwenden(farbe) if !@spiel_informations_sicht.kommunikationen[@spieler_index].nil?
  end

  def nicht_kommuniziert_verwenden(farbe)
    @moegliche_karten.push(Karte.new(wert: 6.5, farbe: farbe))
    @moegliche_karten.push(Karte.new(wert: 3.5, farbe: farbe))
    @sichere_karten.push(Karte.new(wert: 6.5, farbe: farbe))
    @sichere_karten.push(Karte.new(wert: 3.5, farbe: farbe))
  end

  def kommuniziert_verwenden(farbe)
    kommunikation = @spiel_informations_sicht.kommunikationen[@spieler_index]
    stiche = @spiel_informations_sicht.stiche
    return if kommunikation.karte.farbe == farbe ||
              stiche[kommunikation.gegangene_stiche..].any? {|stich| stich.karten.any? {|karte| karte.farbe == farbe}}
    nicht_kommuniziert_verwenden(farbe)
  end

  def min_auftraege_lege_wkeit(spieler_index:, karte:)
    wkeit = 0
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    moegliche_auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].dup
    moegliche_auftraege.select! {|auftrag|
      @moegliche_karten.any? {|moegliche_karte| moegliche_karte == auftrag.karte}
    }
    moegliche_auftraege.each do |auftrag|
      auftrag_wkeit = min_wkeit_auftrag_legen(spieler_index: spieler_index, farbe: farbe, auftrag: auftrag)
      wkeit = 1 - (1 - wkeit) * (1 - auftrag_wkeit)
    end
    wkeit
  end

  def max_auftraege_lege_wkeit(spieler_index:, karte:)
    wkeit = 0
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    moegliche_auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].dup
    moegliche_auftraege.select! {|auftrag|
      @moegliche_karten.any? {|moegliche_karte| moegliche_karte == auftrag.karte}
    }
    moegliche_auftraege.each do |auftrag|
      auftrag_wkeit = max_wkeit_auftrag_legen(spieler_index: spieler_index, farbe: farbe, auftrag: auftrag)
      wkeit = 1 - (1 - wkeit) * (1 - auftrag_wkeit)
    end
    wkeit
  end

  def min_wkeit_auftrag_legen(spieler_index:, farbe:, auftrag:)
    hat_auftrag_sicher = @spiel_informations_sicht.sichere_karten(spieler_index).any? {|karte| karte == auftrag.karte}
    if auftrag.farbe == farbe && hat_auftrag_sicher
       0.75 ** (@moegliche_karten.select{|karte| karte.farbe == auftrag.farbe}.length - 1)
    elsif auftrag.farbe == farbe
      0.75 ** (@moegliche_karten.select{|karte| karte.farbe == auftrag.farbe}.length - 1) * 0.25
    else
      0
    end
  end

  def max_wkeit_auftrag_legen(spieler_index:, farbe:, auftrag:)
    hat_auftrag_sicher = @spiel_informations_sicht.sichere_karten(spieler_index).any? {|karte| karte == auftrag.karte}
    if auftrag.farbe == farbe && hat_auftrag_sicher
      1
    elsif auftrag.farbe == farbe
      0.25
    elsif hat_auftrag_sicher
      0.75 ** @moegliche_karten.select{|karte| karte.farbe == auftrag.farbe}.length
    else
      0.25 * 0.75 ** @moegliche_karten.select{|karte| karte.farbe == auftrag.farbe}.length
    end
  end

  def gespielt?
    @spieler_index == 0 or @spieler_index + @stich.karten.length >= @spiel_informations_sicht.anzahl_spieler
  end

  def min_sieges_wkeit(staerkste_karte)
    return 0 if gespielt?
    return 0 if @spiel_informations_sicht.sichere_karten(@spieler_index).any? {|karte|
      !karte.schlaegt?(staerkste_karte) && staerkste_karte.farbe == karte.farbe}
    moegliche_tiefere_karten = @strikt_moegliche_karten.select {|karte|
      !karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe
    }
    if @sichere_karten.any? {|karte| karte.farbe == staerkste_karte.farbe && karte.schlaegt?(staerkste_karte)}
      kann_hoeher = 1
    else
      moegliche_hoehere_karten = @strikt_moegliche_karten.select {|karte|
        karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe
      }
      kann_hoeher = 1 - 0.75 ** moegliche_hoehere_karten.length
    end
    (1 - (1 - 0.75 ** moegliche_tiefere_karten.length)) * kann_hoeher
  end

  def max_sieges_wkeit(staerkste_karte)
    return 0 if gespielt?
    return 1 if @spiel_informations_sicht.sichere_karten(@spieler_index).any? {|karte|
      karte.schlaegt?(staerkste_karte) && staerkste_karte.farbe == karte.farbe}
    if @sichere_karten.any? {|karte| karte.farbe == staerkste_karte.farbe && karte.schlaegt?(staerkste_karte)} ||
       (@sichere_karten.all? {|karte| karte.farbe != staerkste_karte.farbe} &&
        @sichere_karten.any? {|karte| karte.schlaegt?(staerkste_karte)})
      1
    else
      moegliche_hoehere_karten = @strikt_moegliche_karten.select {|karte|
        karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe
      }
      (1 - 0.75 ** moegliche_hoehere_karten.length)
    end
  end
end
