# coding: utf-8
# verwaltet die erwartete Hand eines beliebigen Spielers für den Schimpansen
class SchimpansenHand
  def initialize(stich:, spiel_informations_sicht:, spieler_index:)
    @spieler_index = spieler_index
    @spiel_informations_sicht = spiel_informations_sicht
    @stich = stich
    @moegliche_karten = @spiel_informations_sicht.moegliche_karten(spieler_index)
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
    elsif auftrag.farbe
      0.25
    else
      0
    end
  end

  def gespielt?
    @spieler_index == 0 or @spieler_index + @stich.karten.length >= @spiel_informations_sicht.anzahl_spieler
  end

  def min_sieges_wkeit(staerkste_karte)
    return 0 if gespielt?
    return 0 if @spiel_informations_sicht.sichere_karten(@spieler_index).any? {|karte|
      !karte.schlaegt?(staerkste_karte) && staerkste_karte.farbe == karte.farbe}
    hoehere_karten = @moegliche_karten.select {|karte| karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe}
    tiefere_karten = @moegliche_karten.select {|karte| !karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe}
    (1 - (1 - 0.75 ** tiefere_karten.length)) * (1 - 0.75 ** hoehere_karten.length)
  end

  def max_sieges_wkeit(staerkste_karte)
    return 0 if gespielt?
    return 1 if @spiel_informations_sicht.sichere_karten(@spieler_index).any? {|karte|
      karte.schlaegt?(staerkste_karte) && staerkste_karte.farbe == karte.farbe}
    hoehere_karten = @moegliche_karten.select {|karte| karte.schlaegt?(staerkste_karte) && karte.farbe == staerkste_karte.farbe}
    (1 - 0.75 ** hoehere_karten.length)
  end
end
