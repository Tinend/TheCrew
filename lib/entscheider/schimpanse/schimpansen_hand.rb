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

  attr_reader :min_schlag_werte, :max_schlag_werte

  def ich_lege_karte(karte)
    return if @spieler_index != 0
    if @stich.length == 0
      @min_schlag_werte[karte.farbe] = Array.new(15,0)
      @min_schlag_werte[karte.farbe][karte.schlag_wert] = 1
      @max_schlag_werte[karte.farbe] = Array.new(15,0)
      @max_schlag_werte[karte.farbe][karte.schlag_wert] = 1
    elsif karte.schlaegt?(@stich.staerkste_karte)
      @min_schlag_werte[@stich.farbe] = Array.new(15,0)
      @min_schlag_werte[@stich.farbe][karte.schlag_wert] = 1
      @max_schlag_werte[@stich.farbe] = Array.new(15,0)
      @max_schlag_werte[@stich.farbe][karte.schlag_wert] = 1
    else
      @min_schlag_werte[@stich.farbe] = Array.new(15,0)
      @min_schlag_werte[@stich.farbe][0] = 1
      @max_schlag_werte[@stich.farbe] = Array.new(15,0)
      @max_schlag_werte[@stich.farbe][0] = 1
    end
  end
  
  def erzeuge_schlag_werte(farben:)
    if @spieler_index == 0
      @min_schlag_werte = {}
      @max_schlag_werte = {}
    elsif gespielt?
      erzeuge_sichere_schlag_werte(farben: farben)
    else
      erzeuge_unsichere_schlag_werte(farben: farben)
    end
  end

  def erzeuge_sichere_schlag_werte(farben:)
    @min_schlag_werte = {}
    @max_schlag_werte = {}
    farben.each do |farbe|
      @min_schlag_werte[farbe] = Array.new(15, 0)
      @max_schlag_werte[farbe] = Array.new(15, 0)
      if @stich.sieger_index == @spieler_index
        @min_schlag_werte[farbe][@stich.staerkste_karte.schlag_wert] = 1
        @max_schlag_werte[farbe][@stich.staerkste_karte.schlag_wert] = 1
      else
        @min_schlag_werte[farbe][0] = 1
        @max_schlag_werte[farbe][0] = 1
      end
    end
  end

  def erzeuge_unsichere_schlag_werte(farben:)
    #@karten_wkeiten.each do |karten_wkeit|
    #  print "#{karten_wkeit[0]} #{karten_wkeit[1]}  "
    #end
    #puts
    @min_schlag_werte = {}
    @max_schlag_werte = {}
    farben.each do |farbe|
      @min_schlag_werte[farbe] = Array.new(15) {|schlag_wert|
        min_schlag_wert(schlag_wert: schlag_wert, farbe: farbe)
      }
      @min_schlag_werte[farbe][0] = 1 - @min_schlag_werte[farbe][1..].sum
      @max_schlag_werte[farbe] = Array.new(15) {|schlag_wert|
        max_schlag_wert(schlag_wert: schlag_wert, farbe: farbe)
      }
      @max_schlag_werte[farbe][0] = 1 - @max_schlag_werte[farbe][1..].sum
    end
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
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index] -
                @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?
    @blank_wkeiten[farbe] * @karten_wkeiten.reduce(1) {|wkeit, karten_wkeit|
      if karten_wkeit[0].farbe != farbe && !auftraege.any? {|auftrag| auftrag.karte == karten_wkeit[0]}
        wkeit * (1 - karten_wkeit[1])
      else
        wkeit
      end
    } * auftraege.reduce(1) {|produkt, auftrag| produkt * @karten_wkeiten[auftrag.karte]}
  end

  def unblank_min_auftraege_legen_wkeit(spieler_index:, karte:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?
    (1 - @blank_wkeiten[farbe]) * @karten_wkeiten.reduce(1) {|wkeit, karten_wkeit|
      if karten_wkeit[0].farbe == farbe && !auftraege.any? {|auftrag| auftrag.karte == karten_wkeit[0]}
        wkeit * (1 - karten_wkeit[1])
      else
        wkeit
      end
    } * auftraege.reduce(1) {|produkt, auftrag| produkt * @karten_wkeiten[auftrag.karte]}
  end

  def min_auftraege_lege_wkeit(spieler_index:, karte:)
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    wkeit = blank_min_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit *= unblank_min_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit
  end

  def blank_max_auftraege_legen_wkeit(spieler_index:, karte:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index] -
                @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?
    @blank_wkeiten[farbe] * auftraege.reduce(1) {|wkeit, auftrag|
      wkeit * (1 - @karten_wkeiten[auftrag.karte])
    }
  end

  def unblank_max_auftraege_legen_wkeit(spieler_index:, karte:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?
    (1 - @blank_wkeiten[farbe]) * auftraege.reduce(1) {|wkeit, auftrag|
      wkeit * (1 - @karten_wkeiten[auftrag.karte])
    }
  end

  def max_auftraege_lege_wkeit(spieler_index:, karte:)
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    wkeit = blank_max_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit *= unblank_max_auftraege_legen_wkeit(spieler_index: spieler_index, karte: karte, farbe: farbe)
    wkeit
  end

  def nur_trumpf_uebrig_wkeit
    @blank_wkeiten.reduce(1) {|produkt, farbe|
      if farbe[0].trumpf?
        produkt
      else
        produkt * farbe[1]
      end
    }
  end

  def min_schlag_wert(schlag_wert:, farbe:)
    return 0 if schlag_wert == 10 || @stich.length != 0 && @stich.staerkste_karte.schlag_wert >= schlag_wert
    kleiner_wkeit = 0
    gleich_wkeit = 0
    @karten_wkeiten.each do |karten_wkeit|
      if karten_wkeit[0].farbe == farbe && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1]
      elsif karten_wkeit[0].trumpf? && !farbe.trumpf? && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1] * nur_trumpf_uebrig_wkeit
      elsif schlag_wert > karten_wkeit[0].schlag_wert && karten_wkeit[0].farbe == farbe
        kleiner_wkeit = 1 - (1 - kleiner_wkeit) * (1 - karten_wkeit[1])
      elsif schlag_wert > karten_wkeit[0].schlag_wert && karten_wkeit[0].trumpf? && !farbe.trumpf?
        kleiner_wkeit = 1 - (1 - kleiner_wkeit) * (1 - karten_wkeit[1] * nur_trumpf_uebrig_wkeit)
      end
    end
    (1 - kleiner_wkeit) * gleich_wkeit
  end

  def max_schlag_wert(schlag_wert:, farbe:)
    return 0 if schlag_wert == 10 || @stich.length != 0 && @stich.staerkste_karte.schlag_wert >= schlag_wert
    groesser_wkeit = 0
    gleich_wkeit = 1
    @karten_wkeiten.each do |karten_wkeit|
      if karten_wkeit[0].farbe == farbe && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1]
      elsif karten_wkeit[0].trumpf? && !farbe.trumpf? && karten_wkeit[0].schlag_wert == schlag_wert
        gleich_wkeit = karten_wkeit[1] * @blank_wkeiten[farbe]
      elsif schlag_wert < karten_wkeit[0].schlag_wert && karten_wkeit[0].farbe == farbe
        groesser_wkeit = 1 - (1 - groesser_wkeit) * (1 - karten_wkeit[1])
      elsif schlag_wert < karten_wkeit[0].schlag_wert && karten_wkeit[0].trumpf? && !farbe.trumpf?
        groesser_wkeit = 1 - (1 - groesser_wkeit) * (1 - karten_wkeit[1] * @blank_wkeiten[farbe])
      end
    end
    (1 - groesser_wkeit) * gleich_wkeit
  end

  #def max_schlag_wert(schlag_wert:, staerkste_karte:)
  #  return 0 if schlag_wert <= staerkste_karte.schlag_wert || schlag_wert == 10
  #  groesser_wkeit = 0
  #  gleich_wkeit = 1
  #  @karten_wkeiten.each do |karten_wkeit|
  #    if karten_wkeit[0].farbe == staerkste_karte.farbe && karten_wkeit[0].schlag_wert == schlag_wert
  #      gleich_wkeit = karten_wkeit[1]
  #    elsif karten_wkeit[0].trumpf? && !staerkste_karte.trumpf? && karten_wkeit[0].schlag_wert == schlag_wert
  #      gleich_wkeit = karten_wkeit[1] * @blank_wkeiten[staerkste_karte.farbe]
  #    elsif schlag_wert < karten_wkeit[0].schlag_wert && karten_wkeit[0].farbe == staerkste_karte.farbe
  #      groesser_wkeit = 1 - (1 - groesser_wkeit) * (1 - karten_wkeit[1])
  #    elsif schlag_wert < karten_wkeit[0].schlag_wert && karten_wkeit[0].trumpf? && !staerkste_karte.trumpf?
  #      groesser_wkeit = 1 - (1 - groesser_wkeit) * (1 - karten_wkeit[1] * @blank_wkeiten[staerkste_karte.farbe])
  #    end
  #  end
  #  (1 - groesser_wkeit) * gleich_wkeit
  #end

  def gespielt?
    @spieler_index.zero? or @spieler_index + @stich.karten.length >= @spiel_informations_sicht.anzahl_spieler
  end

end
