# coding: utf-8
# frozen_string_literal: true

# Berechnet wie gut es ist, eine bestimmte Karte zu legen

# Für den Schimpansen gemacht
class SchimpansenKartenWertBerechner
  AUFTRAG_FARB_WERT = 0.14

  def initialize(spiel_informations_sicht:, stich:, karte:, haende:)
    @karte = karte
    @spiel_informations_sicht = spiel_informations_sicht
    @stich = stich
    @min_auftraege_wkeit = Array.new(anzahl_spieler, 0.0)
    @max_auftraege_wkeit = Array.new(anzahl_spieler, 0.0)
    @min_sieges_wkeit = Array.new(anzahl_spieler, 0.0)
    @max_sieges_wkeit = Array.new(anzahl_spieler, 0.0)
    @blank_werte = Array.new(anzahl_spieler, 0.0)
    @moegliche_auftraege = @spiel_informations_sicht.unerfuellte_auftraege.collect(&:dup)
    @moegliche_auftraege.each do |auftrag_liste|
      auftrag_liste.reject! do |auftrag|
        auftrag.karte == @karte || @stich.karten.any? { |stich_karte| auftrag.karte == stich_karte }
      end
    end
    @farbe = if @stich.karten.empty?
               @karte.farbe
             else
               @stich.farbe
             end
    @haende = haende
  end

  def wert
    auftraege_berechnen
    sieges_wkeiten_berechnen
    vorresultat = -@min_sieges_wkeit.zip(@min_auftraege_wkeit).collect do |sieges_auftrag_wkeit|
      (1 - sieges_auftrag_wkeit[0]) * sieges_auftrag_wkeit[1]
    end.reduce(:+)
    resultate = Array.new(anzahl_spieler) do |spieler_index|
      resultat = vorresultat + ((1 - @min_sieges_wkeit[spieler_index]) * @min_auftraege_wkeit[spieler_index])
      resultat + (@max_sieges_wkeit[spieler_index] * @max_auftraege_wkeit[spieler_index])
    end
    # puts "#{@karte} #{resultate.max}"
    # p vorresultat
    # p @min_sieges_wkeit
    # p @max_sieges_wkeit
    # p @min_auftraege_wkeit
    # p @max_auftraege_wkeit
    # p resultate
    resultate.max + auftrag_farb_wert_berechnen
  end

  def auftrag_farb_wert_berechnen
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.farbe == @karte.farbe } &&
       @stich.length.zero?
      AUFTRAG_FARB_WERT
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.farbe == @karte.farbe } &&
          !@stich.empty?
      -AUFTRAG_FARB_WERT
    else
      0
    end
  end

  # mich selbst eingeschlossen
  def anzahl_ungespielte_spieler
    anzahl_spieler - @stich.length
  end

  # Liest die Aufträge aus dem Stich, wenn diese Karte gelegt wird
  def auftraege_aus_stich_lesen
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrag_liste, spieler_index|
      @stich.karten.each do |karte|
        if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
          @min_auftraege_wkeit[spieler_index] += 1
          @max_auftraege_wkeit[spieler_index] += 1
        end
      end
      if auftrag_liste.any? { |auftrag| auftrag.karte == @karte }
        @min_auftraege_wkeit[spieler_index] += 1
        @max_auftraege_wkeit[spieler_index] += 1
      end
    end
  end

  def anzahl_spieler
    @spiel_informations_sicht.anzahl_spieler
  end

  def auftraege_berechnen
    auftraege_aus_stich_lesen
    max_spieler_index = anzahl_spieler - 1 - @stich.karten.length
    (1..max_spieler_index).each do |spieler_index|
      auftraege_von_spieler_berechnen(spieler_index: spieler_index)
    end
  end

  def auftraege_von_spieler_berechnen(spieler_index:)
    (0..anzahl_spieler - 1).each do |auftrag_spieler_index|
      auftraege_von_spieler_fuer_spieler_berechnen(
        karten_spieler_index: spieler_index,
        auftrag_spieler_index: auftrag_spieler_index
      )
    end
  end

  def auftraege_von_spieler_fuer_spieler_berechnen(karten_spieler_index:, auftrag_spieler_index:)
    min_wkeit = @haende[karten_spieler_index].min_auftraege_lege_wkeit(spieler_index: auftrag_spieler_index,
                                                                       karte: @karte)
    @min_auftraege_wkeit[auftrag_spieler_index] =
      1 - ((1 - @min_auftraege_wkeit[auftrag_spieler_index]) * (1 - min_wkeit))
    max_wkeit = @haende[karten_spieler_index].max_auftraege_lege_wkeit(spieler_index: auftrag_spieler_index,
                                                                       karte: @karte)
    @max_auftraege_wkeit[auftrag_spieler_index] =
      1 - ((1 - @max_auftraege_wkeit[auftrag_spieler_index]) * (1 - max_wkeit))
  end

  def berechne_staerkste_karte
    staerkste_karte = @karte
    if @stich.karten.length.positive? && !@karte.schlaegt?(@stich.staerkste_karte)
      staerkste_karte = @stich.staerkste_karte
    end
    staerkste_karte
  end

  def ueberarbeite_sieges_wkeiten_mit_staerkster_karte(staerkste_karte)
    @min_sieges_wkeit.collect!.with_index do |wkeit, spieler_index|
      1 - ((1 - wkeit) * (1 - @haende[spieler_index].min_sieges_wkeit(staerkste_karte)))
    end
    @max_sieges_wkeit.collect!.with_index do |wkeit, spieler_index|
      1 - ((1 - wkeit) * (1 - @haende[spieler_index].max_sieges_wkeit(staerkste_karte)))
    end
  end

  def sieges_wkeiten_berechnen
    staerkste_karte = berechne_staerkste_karte
    ueberarbeite_sieges_wkeiten_mit_staerkster_karte(staerkste_karte)
    staerkster_index = if staerkste_karte == @karte
                         0
                       else
                         @stich.karten.find_index(staerkste_karte) - @stich.karten.length
                       end
    @min_sieges_wkeit[staerkster_index] = [1 - @max_sieges_wkeit.reduce(:+), 0].max
    @max_sieges_wkeit[staerkster_index] =
      [1 - @min_sieges_wkeit.reduce(:+) + @min_sieges_wkeit[staerkster_index], 0].max
  end
end
