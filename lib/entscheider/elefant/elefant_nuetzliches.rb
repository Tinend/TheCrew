# coding: utf-8
# ein paar nützliche Funktionen, die an- und abspielen brauchen
module ElefantNuetzliches

  HOHE_KARTE_UNTERBIETEN = 6

  def karte_ist_auftrag_von(karte)
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrags_liste, index|
      return index if auftrags_liste.any? {|auftrag| auftrag.karte == karte}
    end
    nil
  end

  def finde_auftrag_in_stich(stich)
    stich.karten.each do |karte|
      @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
        return spieler_index if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
      end
    end
    nil
  end

  def auftraege_mit_farbe_berechnen(farbe)
    @spiel_informations_sicht.unerfuellte_auftraege.collect {|auftrag_liste|
      auftrag_liste.count {|auftrag| auftrag.farbe == farbe}
    }
  end

  def hat_gespielt?(spieler_index:, stich:)
    stich.length + spieler_index >= @spiel_informations_sicht.anzahl_spieler
  end

  def jeder_kann_unterbieten?(karte:, end_index: @spiel_informations_sicht.anzahl_spieler - 1)
    (1..end_index).all? {|spieler_index|
      spieler_kann_unterbieten?(karte: karte, spieler_index: spieler_index)
    }
  end

  def spieler_kann_unterbieten?(karte:, spieler_index:)
    @spiel_informations_sicht.sichere_karten(spieler_index).each do |test_karte|
      return true if karte.farbe == test_karte.farbe && karte.wert > test_karte.wert
    end
    if karte.wert >= HOHE_KARTE_UNTERBIETEN
      @spiel_informations_sicht.moegliche_karten(spieler_index).each do |test_karte|
        return true if karte.farbe == test_karte.farbe && karte.wert > test_karte.wert
      end
    end
    @spiel_informations_sicht.sichere_karten(spieler_index).each do |test_karte|
      return false if karte.farbe == test_karte.farbe && karte.wert < test_karte.wert
    end
    @spiel_informations_sicht.moegliche_karten(spieler_index).each do |test_karte|
      return false if karte.farbe == test_karte.farbe && karte.wert < test_karte.wert
    end
    true
  end

  def tiefster_eigener_auftrag_mit_farbe(farbe)
    @spiel_informations_sicht.auftraege_mit_farbe(farbe)[0].min_by {|auftrag|
      auftrag.karte.wert
    }
  end

  def habe_hohe_karte_mit_farbe?(farbe:, wert:)
    @spiel_informations_sicht.karten_mit_farbe(farbe).any? {|karte|
      karte.wert >= wert
    }
  end

  def kurze_farbe?(farbe:)
    berechne_farb_laenge(farbe: farbe) < 1
  end

  def lange_farbe?(farbe:)
    berechne_farb_laenge(farbe: farbe) > 1
  end

  def berechne_farb_laenge(farbe:)
    laenge = @spiel_informations_sicht.karten_mit_farbe(farbe).length
    verbliebene_karten = Karte.alle_mit_farbe(farbe).count {|karte|
      !@spiel_informations_sicht.ist_gegangen?(karte)
    }
    laenge * @spiel_informations_sicht.anzahl_spieler.to_f / verbliebene_karten
  end
  
  def habe_noch_auftraege?
    !@spiel_informations_sicht.unerfuellte_auftraege[0].empty?
  end
end
