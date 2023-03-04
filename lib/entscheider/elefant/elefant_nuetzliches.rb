# coding: utf-8
# frozen_string_literal: true

# ein paar nützliche Funktionen, die an- und abspielen brauchen
module ElefantNuetzliches
  HOHE_KARTE_UNTERBIETEN = 6
  HOHE_KARTE_UEBERBIETEN = 6

  def karte_ist_auftrag_von(karte)
    # puts karte
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrags_liste, index|
      return index if auftrags_liste.any? { |auftrag| auftrag.karte == karte }
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
    @spiel_informations_sicht.unerfuellte_auftraege.collect.with_index do |auftrag_liste, _index|
      auftrag_liste.count { |auftrag| auftrag.farbe == farbe }
    end
  end

  def hat_gespielt?(spieler_index:, stich:)
    stich.length + spieler_index >= @spiel_informations_sicht.anzahl_spieler
  end

  def jeder_kann_unterbieten?(karte:, end_index: @spiel_informations_sicht.anzahl_spieler - 1)
    (1..end_index).all? do |spieler_index|
      spieler_kann_unterbieten?(karte: karte, spieler_index: spieler_index)
    end
  end

  def legt_sicher_tiefere_karte?(karte:, spieler_index:)
    @spiel_informations_sicht.sichere_karten(spieler_index).each do |test_karte|
      return true if karte.farbe == test_karte.farbe && karte.wert > test_karte.wert
    end
    false
  end

  def legt_vielleicht_tiefere_karte?(karte:, spieler_index:)
    @spiel_informations_sicht.moegliche_karten(spieler_index).each do |test_karte|
      return true if karte.farbe == test_karte.farbe && karte.wert > test_karte.wert
    end
    false
  end

  def legt_vielleicht_hoehere_karte?(karte:, spieler_index:)
    @spiel_informations_sicht.moegliche_karten(spieler_index).each do |test_karte|
      return true if karte.farbe == test_karte.farbe && karte.wert < test_karte.wert
    end
    false
  end

  def legt_sicher_hoehere_karte?(karte:, spieler_index:)
    @spiel_informations_sicht.sichere_karten(spieler_index).each do |test_karte|
      return true if karte.farbe == test_karte.farbe && karte.wert < test_karte.wert
    end
    false
  end

  def spieler_kann_unterbieten?(karte:, spieler_index:)
    return true if legt_sicher_tiefere_karte?(karte: karte, spieler_index: spieler_index) ||
                   (karte.wert >= HOHE_KARTE_UNTERBIETEN &&
                   legt_vielleicht_tiefere_karte?(karte: karte, spieler_index: spieler_index))
    return false if legt_vielleicht_hoehere_karte?(karte: karte, spieler_index: spieler_index)

    true
  end

  def tiefster_eigener_auftrag_auf_fremder_hand_mit_farbe(farbe)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe)[0].select do |auftrag|
      @spiel_informations_sicht.karten.all? { |karte| karte != auftrag.karte }
    end
    return nil if auftraege.empty?

    auftraege.min_by do |auftrag|
      auftrag.karte.wert
    end
  end

  def habe_hohe_karte_mit_farbe?(farbe:, wert:)
    @spiel_informations_sicht.karten_mit_farbe(farbe).any? do |karte|
      karte.wert >= wert
    end
  end

  def kurze_farbe?(farbe:)
    berechne_farb_laenge(farbe: farbe) < 1
  end

  def lange_farbe?(farbe:)
    berechne_farb_laenge(farbe: farbe) > 1
  end

  def berechne_farb_laenge(farbe:)
    laenge = @spiel_informations_sicht.karten_mit_farbe(farbe).length
    verbliebene_karten = Karte.alle_mit_farbe(farbe).count do |karte|
      !@spiel_informations_sicht.ist_gegangen?(karte)
    end
    laenge * @spiel_informations_sicht.anzahl_spieler.to_f / verbliebene_karten
  end

  def habe_noch_auftraege?
    !@spiel_informations_sicht.unerfuellte_auftraege[0].empty?
  end

  def kann_ueberbieten?(karte:, spieler_index:)
    (1..@spiel_informations_sicht.anzahl_spieler - 1).all? do |index|
      if index == spieler_index
        @spiel_informations_sicht.moegliche_karten(spieler_index).any? do |moegliche_karte|
          moegliche_karte.wert >= 7 && moegliche_karte.farbe == karte.farbe
        end
      else
        spieler_kann_unterbieten?(karte: Karte.new(farbe: karte.farbe, wert: 7), spieler_index: index)
      end
    end
  end

  def kann_schlagen?(karte:, spieler_index:)
    return true if legt_sicher_hoehere_karte?(karte: karte, spieler_index: spieler_index) ||
                   (karte.wert <= HOHE_KARTE_UEBERBIETEN &&
                   legt_vielleicht_hoehere_karte?(karte: karte, spieler_index: spieler_index))
    return false if legt_vielleicht_tiefere_karte?(karte: karte, spieler_index: spieler_index) ||
                    karte.trumpf?

    true
  end
end
