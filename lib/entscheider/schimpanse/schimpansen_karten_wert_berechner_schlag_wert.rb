module SchimpansenKartenWertBerechnerSchlagWert
  SCHLAG_WERT_ARRAY_LAENGE = 15

  def schlag_werte_wkeiten_aufsetzen(staerkste_karte:)
    #@min_schlag_werte_wkeiten = Array.new(anzahl_spieler) {|spieler_index|
    #  Array.new(SCHLAG_WERT_ARRAY_LAENGE) {|schlag_wert|
    #    @haende[spieler_index].min_schlag_wert(schlag_wert: schlag_wert, staerkste_karte: staerkste_karte)
    #  }
    #}
    #@max_schlag_werte_wkeiten = Array.new(anzahl_spieler) {|spieler_index|
    #  Array.new(SCHLAG_WERT_ARRAY_LAENGE) {|schlag_wert|
    #    @haende[spieler_index].max_schlag_wert(schlag_wert: schlag_wert, staerkste_karte: staerkste_karte)
    #  }
    #}
  end

  def schlag_werte_stich_einbeziehen(staerkster_index:, staerkste_karte:)
    #@min_schlag_werte_wkeiten[0] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
    #@max_schlag_werte_wkeiten[0] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
    #(anzahl_spieler - @stich.length..anzahl_spieler - 1).each do |spieler_index|
      #@min_schlag_werte_wkeiten[spieler_index] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
      #@max_schlag_werte_wkeiten[spieler_index] = Array.new(SCHLAG_WERT_ARRAY_LAENGE, 0)
    #end
    #@min_schlag_werte_wkeiten[staerkster_index][staerkste_karte.schlag_wert] = 1
    #@max_schlag_werte_wkeiten[staerkster_index][staerkste_karte.schlag_wert] = 1
  end

  def schlag_werte_normieren
    #@min_schlag_werte_wkeiten.each do |schlag_werte|
    #  schlag_werte[0] = 1 - schlag_werte.sum
    #end
    #@max_schlag_werte_wkeiten.each do |schlag_werte|
    #  schlag_werte[0] = 1 - schlag_werte.sum
    #end
  end

  def schlag_werte_wkeiten_in_summen_umwandeln
    summe = 0
    farbe = @karte.farbe
    farbe = @stich.farbe if @stich.length > 0
    @haende[0].ich_lege_karte(@karte)
    @min_schlag_werte_wkeiten_summe = @haende.collect {|hand|
      summe = 0
      hand.min_schlag_werte[farbe].collect {|schlag_wert_wkeit|
        summe += schlag_wert_wkeit
      }
    }
    @max_schlag_werte_wkeiten_summe = @haende.collect {|hand|
      summe = 0
      hand.max_schlag_werte[farbe].collect {|schlag_wert_wkeit|
        summe += schlag_wert_wkeit
      }
    }
    #@max_schlag_werte_wkeiten_summe = @max_schlag_werte_wkeiten.collect {|max_schlag_werte_wkeiten|
    ##  summe = 0
     # max_schlag_werte_wkeiten.collect {|schlag_wert_wkeit|
    #    summe += schlag_wert_wkeit
    #  }
    #}
  end

  def schlag_werte_wkeiten_berechnen(staerkste_karte:, staerkster_index:)
    #schlag_werte_wkeiten_aufsetzen(staerkste_karte: staerkste_karte)
    #schlag_werte_stich_einbeziehen(staerkste_karte: staerkste_karte, staerkster_index: staerkster_index)
    #schlag_werte_normieren
    schlag_werte_wkeiten_in_summen_umwandeln
  end

  def sieges_wkeiten_aus_schlagwert_berechnen
    farbe = @karte.farbe
    farbe = @stich.farbe if @stich.length > 0
    #puts 1
    @min_sieges_wkeit = @haende.collect.with_index {|hand, spieler_index|
      schlag_wert = -1
      #p [farbe, spieler_index]
      #p hand.min_schlag_werte[farbe]
      #p @max_schlag_werte_wkeiten_summe
      hand.min_schlag_werte[farbe].reduce(0) {|summe, wkeit|
        schlag_wert += 1
        index = -1
        andere_wkeiten = @max_schlag_werte_wkeiten_summe.reduce(1) {|produkt, wkeit_summe|
          index += 1
          if index == spieler_index
            produkt
          else
            produkt * wkeit_summe[schlag_wert]
          end
        }
        #p [wkeiten_summen, schlag_wert]
        summe + wkeit * andere_wkeiten
      }
    }
    #p @min_sieges_wkeit
    #puts 2
    @max_sieges_wkeit = @haende.collect.with_index {|hand, spieler_index|
      schlag_wert = -1
      #p [farbe, spieler_index]
      #p hand.max_schlag_werte[farbe]
      #p @min_schlag_werte_wkeiten_summe
      hand.max_schlag_werte[farbe].reduce(0) {|summe, wkeit|
        schlag_wert += 1
        index = -1
        andere_wkeiten = @min_schlag_werte_wkeiten_summe.reduce(1) {|produkt, wkeit_summe|
          index += 1
          if index == spieler_index
            produkt
          else
            produkt * wkeit_summe[schlag_wert]
          end
        }
        summe + wkeit * andere_wkeiten
      }
    }
    #p @max_sieges_wkeit
   # @min_sieges_wkeit = @min_schlag_werte_wkeiten.collect.with_index {|min_schlag_werte_wkeiten, spieler_index|
   #   schlag_wert = -1
   #   min_schlag_werte_wkeiten.reduce(0) {|summe, wkeit|
   #     schlag_wert += 1
   #     wkeiten_summen = @max_schlag_werte_wkeiten_summe.collect.with_index {|wkeit_summe, index|
   #       if index == spieler_index
   #         1
   #       else
   #         wkeit_summe[schlag_wert]
   #       end
   #     }
   #     andere_wkeiten = wkeiten_summen.reduce(:*)
   #     summe + wkeit * andere_wkeiten
   #   }
   # }
    #@max_sieges_wkeit = @max_schlag_werte_wkeiten.collect.with_index {|max_schlag_werte_wkeiten, spieler_index|
    #  schlag_wert = -1
    #  max_schlag_werte_wkeiten.reduce(0) {|summe, wkeit|
    #    schlag_wert += 1
    #    wkeiten_summen = @min_schlag_werte_wkeiten_summe.collect.with_index {|wkeit_summe, index|
    #      if index == spieler_index
    #        1
    #      else
    #        wkeit_summe[schlag_wert]
    #      end
    #    }
    #    andere_wkeiten = wkeiten_summen.reduce(:*)
    #    summe + wkeit * andere_wkeiten
    #  }
    #}
  end
end
