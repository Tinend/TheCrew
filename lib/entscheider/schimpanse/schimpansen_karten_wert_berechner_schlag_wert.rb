# coding: utf-8
# frozen_string_literal: true

# Berechnet einen Array, wie hoch die W'keit ist, für verschiedene Schlag_Werte zu erreichen
module SchimpansenKartenWertBerechnerSchlagWert
  SCHLAG_WERT_ARRAY_LAENGE = 15

  def schlag_werte_wkeiten_in_summen_umwandeln
    summe = 0
    farbe = @karte.farbe
    farbe = @stich.farbe if @stich.length.positive?
    @haende[0].ich_lege_karte(@karte)
    @min_schlag_werte_wkeiten_summe = @haende.collect do |hand|
      summe = 0
      hand.min_schlag_werte[farbe].collect do |schlag_wert_wkeit|
        summe += schlag_wert_wkeit
      end
    end
    @max_schlag_werte_wkeiten_summe = @haende.collect do |hand|
      summe = 0
      hand.max_schlag_werte[farbe].collect do |schlag_wert_wkeit|
        summe += schlag_wert_wkeit
      end
    end
  end

  def schlag_werte_wkeiten_berechnen
    schlag_werte_wkeiten_in_summen_umwandeln
  end

  def berechne_min_sieges_wkeit(farbe)
    @min_sieges_wkeit = @haende.collect.with_index do |hand, spieler_index|
      schlag_wert = -1
      hand.min_schlag_werte[farbe].reduce(0) do |summe, wkeit|
        schlag_wert += 1
        index = -1
        andere_wkeiten = @max_schlag_werte_wkeiten_summe.reduce(1) do |produkt, wkeit_summe|
          index += 1
          if index == spieler_index
            produkt
          else
            produkt * wkeit_summe[schlag_wert]
          end
        end
        summe + (wkeit * andere_wkeiten)
      end
    end
  end

  def berechne_max_sieges_wkeit(farbe)
    @max_sieges_wkeit = @haende.collect.with_index do |hand, spieler_index|
      schlag_wert = -1
      hand.max_schlag_werte[farbe].reduce(0) do |summe, wkeit|
        schlag_wert += 1
        index = -1
        andere_wkeiten = @min_schlag_werte_wkeiten_summe.reduce(1) do |produkt, wkeit_summe|
          index += 1
          if index == spieler_index
            produkt
          else
            produkt * wkeit_summe[schlag_wert]
          end
        end
        summe + (wkeit * andere_wkeiten)
      end
    end
  end

  def sieges_wkeiten_aus_schlagwert_berechnen
    farbe = @karte.farbe
    farbe = @stich.farbe if @stich.length.positive?
    berechne_min_sieges_wkeit(farbe)
    berechne_max_sieges_wkeit(farbe)
  end
end
