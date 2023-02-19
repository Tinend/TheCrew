# coding: utf-8
# frozen_string_literal: true

require_relative 'schimpansen_hand_schlag_werte'

# verwaltet die erwartete Hand eines beliebigen Spielers für den Schimpansen
class SchimpansenHand
  include SchimpansenHandSchlagWerte

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

    farbe = stichfarbe_berechnen(karte)
    # if @stich.length.zero?
    #   @min_schlag_werte[karte.farbe] = Array.new(15, 0)
    #   @min_schlag_werte[karte.farbe][karte.schlag_wert] = 1
    #   @max_schlag_werte[karte.farbe] = Array.new(15, 0)
    #   @max_schlag_werte[karte.farbe][karte.schlag_wert] = 1
    # elsif karte.schlaegt?(@stich.staerkste_karte)
    #  @min_schlag_werte[@stich.farbe] = Array.new(15, 0)
    #  @min_schlag_werte[@stich.farbe][karte.schlag_wert] = 1
    #  @max_schlag_werte[@stich.farbe] = Array.new(15, 0)
    #  @max_schlag_werte[@stich.farbe][karte.schlag_wert] = 1
    if @stich.empty? || karte.schlaegt?(@stich.staerkste_karte)
      @min_schlag_werte[farbe] = Array.new(15, 0)
      @min_schlag_werte[farbe][karte.schlag_wert] = 1
      @max_schlag_werte[farbe] = Array.new(15, 0)
      @max_schlag_werte[farbe][karte.schlag_wert] = 1
    else
      @min_schlag_werte[@stich.farbe] = Array.new(15, 0)
      @min_schlag_werte[@stich.farbe][0] = 1
      @max_schlag_werte[@stich.farbe] = Array.new(15, 0)
      @max_schlag_werte[@stich.farbe][0] = 1
    end
  end

  def stichfarbe_berechnen(karte)
    if @stich.empty?
      karte.farbe
    else
      @stich.farbe
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
    moegliche_wkeit = if @strikt_moegliche_karten.empty?
                        0
                      else
                        (anzahl_karten - @sichere_karten.length).to_f / @strikt_moegliche_karten.length
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

  def blank_min_auftraege_legen_wkeit(spieler_index:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index] -
                @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?

    @blank_wkeiten[farbe] * @karten_wkeiten.reduce(1) do |wkeit, karten_wkeit|
      if karten_wkeit[0].farbe != farbe && auftraege.none? { |auftrag| auftrag.karte == karten_wkeit[0] }
        wkeit * (1 - karten_wkeit[1])
      else
        wkeit
      end
    end * auftraege.reduce(1) { |produkt, auftrag| produkt * @karten_wkeiten[auftrag.karte] }
  end

  def unblank_min_auftraege_legen_wkeit(spieler_index:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?

    (1 - @blank_wkeiten[farbe]) * @karten_wkeiten.reduce(1) do |wkeit, karten_wkeit|
      if karten_wkeit[0].farbe == farbe && auftraege.none? { |auftrag| auftrag.karte == karten_wkeit[0] }
        wkeit * (1 - karten_wkeit[1])
      else
        wkeit
      end
    end * auftraege.reduce(1) { |produkt, auftrag| produkt * @karten_wkeiten[auftrag.karte] }
  end

  def min_auftraege_lege_wkeit(spieler_index:, karte:)
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    wkeit = blank_min_auftraege_legen_wkeit(spieler_index: spieler_index, farbe: farbe)
    wkeit *= unblank_min_auftraege_legen_wkeit(spieler_index: spieler_index, farbe: farbe)
    wkeit
  end

  def blank_max_auftraege_legen_wkeit(spieler_index:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index] -
                @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?

    @blank_wkeiten[farbe] * auftraege.reduce(1) do |wkeit, auftrag|
      wkeit * (1 - @karten_wkeiten[auftrag.karte])
    end
  end

  def unblank_max_auftraege_legen_wkeit(spieler_index:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[spieler_index]
    return 0 if auftraege.empty?

    (1 - @blank_wkeiten[farbe]) * auftraege.reduce(1) do |wkeit, auftrag|
      wkeit * (1 - @karten_wkeiten[auftrag.karte])
    end
  end

  def max_auftraege_lege_wkeit(spieler_index:, karte:)
    farbe = @stich.farbe
    farbe = karte.farbe if @stich.karten.empty?
    wkeit = blank_max_auftraege_legen_wkeit(spieler_index: spieler_index, farbe: farbe)
    wkeit *= unblank_max_auftraege_legen_wkeit(spieler_index: spieler_index, farbe: farbe)
    wkeit
  end

  # Pattern
  def nur_trumpf_uebrig_wkeit
    @blank_wkeiten.reduce(1) do |produkt, farbe|
      if farbe[0].trumpf?
        produkt
      else
        produkt * farbe[1]
      end
    end
  end

  # Pattern
  def erzeuge_blank_wkeiten
    @blank_wkeiten = {}
    Farbe::FARBEN.each do |farbe|
      @blank_wkeiten[farbe] = Karte.alle_mit_farbe(farbe).reduce(1) do |wkeit, karte|
        wkeit * (1 - @karten_wkeiten[karte])
      end
    end
  end

  def gespielt?
    @spieler_index.zero? or @spieler_index + @stich.karten.length >= @spiel_informations_sicht.anzahl_spieler
  end
end
