# coding: utf-8
# frozen_string_literal: true

# Modul für die Schlagwerte der Schimpansen Hand
module SchimpansenHandSchlagWerte
  def erzeuge_schlag_werte(farben:)
    if @spieler_index.zero?
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
    @min_schlag_werte = {}
    @max_schlag_werte = {}
    farben.each do |farbe|
      @min_schlag_werte[farbe] = Array.new(15, 1)
      @max_schlag_werte[farbe] = Array.new(15, 1)
      @min_schlag_werte[farbe][10] = 0
      @max_schlag_werte[farbe][10] = 0
      schlag_werte_trumpf_vorbereiten(farbe) if farbe.trumpf?
      erzeuge_schlag_werte_mit_farbe(farbe)
      @min_schlag_werte[farbe][0] = 1 - @min_schlag_werte[farbe][1..].sum
      @max_schlag_werte[farbe][0] = 1 - @max_schlag_werte[farbe][1..].sum
    end
  end

  def schlag_werte_trumpf_vorbereiten(farbe)
    (1..9).each do |schlag_wert|
      @min_schlag_werte[farbe][schlag_wert] = 0
      @max_schlag_werte[farbe][schlag_wert] = 0
    end
  end

  def erzeuge_schlag_werte_mit_farbe(farbe)
    @karten_wkeiten.each do |karten_wkeit|
      karte = karten_wkeit[0]
      schlag_wert = karte.schlag_wert
      wkeit = karten_wkeit[1]
      if karte.farbe == farbe || (karte.trumpf? && !farbe.trumpf?)
        bestimmte_schlag_werte_setzen(karte: karte, farbe: farbe, wkeit: wkeit, schlag_wert: schlag_wert)
      end
    end
  end

  def bestimmte_schlag_werte_setzen(karte:, farbe:, wkeit:, schlag_wert:)
    if karte.farbe == farbe
      min_wkeit = wkeit
      max_wkeit = wkeit
      min_schlag_wert_multiplikator = 1 - wkeit
      max_schlag_wert_multiplikator = 1 - wkeit
    else
      min_wkeit = wkeit * nur_trumpf_uebrig_wkeit
      max_wkeit = wkeit * @blank_wkeiten[farbe]
      min_schlag_wert_multiplikator = 1 - (wkeit * nur_trumpf_uebrig_wkeit)
      max_schlag_wert_multiplikator = 1 - (wkeit * @blank_wkeiten[farbe])
    end
    @min_schlag_werte[farbe][schlag_wert] *= min_wkeit
    @max_schlag_werte[farbe][schlag_wert] *= max_wkeit
    (schlag_wert + 1..14).each do |groesser_schlag_wert|
      @min_schlag_werte[farbe][groesser_schlag_wert] *= min_schlag_wert_multiplikator
    end
    (1..schlag_wert - 1).each do |kleiner_schlag_wert|
      @max_schlag_werte[farbe][kleiner_schlag_wert] *= max_schlag_wert_multiplikator
    end
  end
end
