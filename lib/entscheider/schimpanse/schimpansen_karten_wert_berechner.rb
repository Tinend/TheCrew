# coding: utf-8
# frozen_string_literal: true

# Berechnet wie gut es ist, eine bestimmte Karte zu legen

# Für den Schimpansen gemacht
class SchimpansenKartenWertBerechner
  AUFTRAG_FARB_WERT = 0.14
  DRAN_KOMM_WERT = 0.01
  EIGENE_AUFTRAEGE_PRIORITAET = 1.5
  SCHLAG_WERT_ARRAY_LAENGE = 15

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
    # @min_schlag_werte_wkeiten = Array.new(anzahl_spieler) {Array.new(14,0)}
    # @max_schlag_werte_wkeiten = Array.new(anzahl_spieler) {Array.new(14,0)}
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

  def risiko_eingehen_wert
    1
  end

  def sieges_auftrag_wkeit_zu_punkten(sieges_auftrag_wkeit)
    sieges_auftrag_wkeit[1] * (sieges_auftrag_wkeit[0] - (1 - sieges_auftrag_wkeit[0]) * risiko_eingehen_wert)
  end

  def sieges_dran_komm_wert_zu_punkten(sieges_dran_komm_wert)
    sieges_dran_komm_wert[1] * (sieges_dran_komm_wert[0] - (1 - sieges_dran_komm_wert[0]) * DRAN_KOMM_WERT)
  end

  def wert
    auftraege_berechnen
    sieges_wkeiten_berechnen
    dran_komm_werte_berechnen
    vorresultat = @min_sieges_wkeit.zip(@min_auftraege_wkeit).reduce(0) do |summe, sieges_auftrag_wkeit|
      summe + sieges_auftrag_wkeit_zu_punkten(sieges_auftrag_wkeit)
    end
    vorresultat += @min_sieges_wkeit.zip(@dran_komm_werte).reduce(0) do |summe, sieges_dran_komm_wert|
      summe + sieges_dran_komm_wert_zu_punkten(sieges_dran_komm_wert)
    end
    resultate = Array.new(anzahl_spieler) do |spieler_index|
      resultat = vorresultat
      resultat -= sieges_auftrag_wkeit_zu_punkten([@min_sieges_wkeit[spieler_index], @min_auftraege_wkeit[spieler_index]])
      resultat += sieges_auftrag_wkeit_zu_punkten([@max_sieges_wkeit[spieler_index], @max_auftraege_wkeit[spieler_index]])
      resultat -= sieges_dran_komm_wert_zu_punkten([@min_sieges_wkeit[spieler_index], @dran_komm_werte[spieler_index]])
      resultat += sieges_dran_komm_wert_zu_punkten([@max_sieges_wkeit[spieler_index], @dran_komm_werte[spieler_index]])
      resultat
    end
    puts "#{@karte} #{resultate.max}"
    p vorresultat
    p @min_sieges_wkeit
    p @max_sieges_wkeit
    p @min_auftraege_wkeit
    p @max_auftraege_wkeit
    p resultate
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

  def dran_komm_werte_berechnen
    @dran_komm_werte = Array.new(anzahl_spieler) { |spieler_index| dran_komm_wert_von_spieler(spieler_index) }
  end

  def dran_komm_wert_von_spieler(spieler_index)
    wert = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].length
    wert = 0.1 if spieler_index == 0 and wert == 0
    wert
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
    @min_auftraege_wkeit[0] *= EIGENE_AUFTRAEGE_PRIORITAET
    @max_auftraege_wkeit[0] *= EIGENE_AUFTRAEGE_PRIORITAET
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

  def schlag_werte_wkeiten_aufsetzen(staerkste_karte:)
    @min_schlag_werte_wkeiten = Array.new(anzahl_spieler) {|spieler_index|
      Array.new(SCHLAG_WERT_ARRAY_LAENGE) {|schlag_wert|
        @haende[spieler_index].min_schlag_wert(schlag_wert: schlag_wert, staerkste_karte: staerkste_karte)
      }
    }
    @max_schlag_werte_wkeiten = Array.new(anzahl_spieler) {|spieler_index|
      Array.new(SCHLAG_WERT_ARRAY_LAENGE) {|schlag_wert|
        @haende[spieler_index].max_schlag_wert(schlag_wert: schlag_wert, staerkste_karte: staerkste_karte)
      }
    }
  end

  def schlag_werte_stich_einbeziehen(staerkster_index:, staerkste_karte:)
    @min_schlag_werte_wkeiten[0] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
    @max_schlag_werte_wkeiten[0] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
    (anzahl_spieler - 1 - @stich.length..anzahl_spieler - 1).each do |spieler_index|
      @min_schlag_werte_wkeiten[spieler_index] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
      @max_schlag_werte_wkeiten[spieler_index] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
    end
    @min_schlag_werte_wkeiten[staerkster_index][staerkste_karte.schlag_wert] = 1
    @max_schlag_werte_wkeiten[staerkster_index][staerkste_karte.schlag_wert] = 1
  end

  def schlag_werte_normieren
    @min_schlag_werte_wkeiten.each do |schlag_werte|
      schlag_werte[0] = 1 - schlag_werte.sum
    end
    @max_schlag_werte_wkeiten.each do |schlag_werte|
      schlag_werte[0] = 1 - schlag_werte.sum
    end
  end

  def schlag_werte_wkeiten_in_summen_umwandeln
    summe = 0
    @min_schlag_werte_wkeiten_summe = @min_schlag_werte_wkeiten.collect {|min_schlag_werte_wkeiten|
      summe = 0
      min_schlag_werte_wkeiten.collect {|schlag_wert_wkeit|
        summe += schlag_wert_wkeit
      }
    }
    @max_schlag_werte_wkeiten_summe = @max_schlag_werte_wkeiten.collect {|max_schlag_werte_wkeiten|
      summe = 0
      max_schlag_werte_wkeiten.collect {|schlag_wert_wkeit|
        summe += schlag_wert_wkeit
      }
    }
  end

  def schlag_werte_wkeiten_berechnen(staerkste_karte:, staerkster_index:)
    schlag_werte_wkeiten_aufsetzen(staerkste_karte: staerkste_karte)
    schlag_werte_stich_einbeziehen(staerkste_karte: staerkste_karte, staerkster_index: staerkster_index)
    schlag_werte_normieren
    schlag_werte_wkeiten_in_summen_umwandeln
  end

  def sieges_wkeiten_aus_schlagwert_berechnen
    @min_sieges_wkeiten = @min_schlag_werte_wkeiten.collect.with_index {|min_schlag_werte_wkeiten, spieler_index|
      schlag_wert = -1
      min_schlag_werte_wkeiten.reduce(0) {|summe, wkeit|
        schlag_wert += 1
        andere_wkeiten = @min_schlag_werte_wkeiten_summe.reduce(0) {|summe2, wkeit_summe| summe2 += wkeit_summe[schlag_wert]}
        andere_wkeiten -= @min_schlag_werte_wkeiten_summe[0][schlag_wert]
        summe + wkeit * andere_wkeiten
      }
    }
    @max_sieges_wkeiten = @max_schlag_werte_wkeiten.collect.with_index {|max_schlag_werte_wkeiten, spieler_index|
      schlag_wert = -1
      max_schlag_werte_wkeiten.reduce(0) {|summe, wkeit|
        schlag_wert += 1
        andere_wkeiten = @max_schlag_werte_wkeiten_summe.reduce(0) {|summe2, wkeit_summe| summe2 += wkeit_summe[schlag_wert]}
        andere_wkeiten -= @max_schlag_werte_wkeiten_summe[0][schlag_wert]
        summe + wkeit * andere_wkeiten
      }
    }
  end
  
  def sieges_wkeiten_berechnen
    staerkste_karte = berechne_staerkste_karte
     #ueberarbeite_sieges_wkeiten_mit_staerkster_karte(staerkste_karte)
    staerkster_index = if staerkste_karte == @karte
                         0
                       else
                         @stich.karten.find_index(staerkste_karte) - @stich.karten.length
                       end
    schlag_werte_wkeiten_berechnen(staerkster_index: staerkster_index, staerkste_karte: staerkste_karte)
    sieges_wkeiten_aus_schlagwert_berechnen
    #@min_sieges_wkeit[staerkster_index] = [1 - @max_sieges_wkeit.reduce(:+), 0].max
    #@max_sieges_wkeit[staerkster_index] =
    #  [1 - @min_sieges_wkeit.reduce(:+) + @min_sieges_wkeit[staerkster_index], 0].max
  end
end
