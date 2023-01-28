# Berechnet wieviel eine Karte Wert ist, um an den Stich zu kommen oder den Stich abzugeben
module SchimpansenInitiative

  PLUS_INITIATIVE = 0.01
  MINUS_INITIATIVE = 0.01
  INITIATIVE_FREMD_FARBE = 0.25
  INITIATIVE_ANDERE_FAKTOR = 0.2
  TRUMPF_INITIATIVE_KARTEN_WERT = 2.5

  def plus_initiative
    verlust_moeglichkeiten = Karte.alle.count {|karte|
      !@spiel_informations_sicht.ist_gegangen?(karte) && @karte.schlaegt?(karte)
    } * plus_initiative_karten_wert * PLUS_INITIATIVE
  end

  def plus_initiative_karten_wert
    if @karte.trumpf?
      TRUMPF_INITIATIVE_KARTEN_WERT + @karte.wert / 4.0
    else
      @karte.wert
    end
  end

  def minus_initiative
    verlust_moeglichkeiten = (Karte.alle - @spiel_informations_sicht.karten).count {|karte|
     !@spiel_informations_sicht.ist_gegangen?(karte) && karte.schlaegt?(@karte)
    } * minus_initiative_karten_wert * MINUS_INITIATIVE
  end

  def minus_initiative_karten_wert
    if @karte.trumpf?
      10 - TRUMPF_INITIATIVE_KARTEN_WERT - @karte.wert / 4.0
    else
      10 - @karte.wert
    end
  end

  def initiative_wert_berechnen
    - plus_initiative - minus_initiative
  end
end
