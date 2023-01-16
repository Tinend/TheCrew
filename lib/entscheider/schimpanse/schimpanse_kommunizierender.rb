# coding: utf-8
# frozen_string_literal: true

require_relative 'schimpanse_kommunikation'

# rubocop:disable Metrics/ModuleLength

# Modul für Schimpanse-Kommunikation
module SchimpanseKommunizierender
  # rubocop:enable Metrics/ModuleLength
  BLANKER_AUFTRAG_PRIORITAET = 1000
  AUFTRAG_NICHT_GEDECKT_PRIORITAET = 100

  def karte_gefaerdet_auftraege_kommunizieren(kommunizierbares)
    schimpansen_kommunikation = nicht_kommunizieren_kommunikation
    auftraege_von_anderen = @spiel_informations_sicht.unerfuellte_auftraege[1..].flatten
    auftraege_von_anderen.each do |auftrag|
      schimpansen_kommunikation.verbessere(
        karte_gefaerdet_auftrag(auftrag: auftrag, kommunizierbares: kommunizierbares)
      )
    end
    schimpansen_kommunikation
  end

  def karte_gefaerdet_auftrag_k_wert(kommunikation:, auftrag:)
    return 100 if kommunikation.karte.farbe != auftrag.farbe

    kommunikation.karte.wert
  end

  # TODO: Andere Lösung für Auftrag könnte geplant sein
  # TODO: Vielleicht hat der Auftragnehmer keine hohe Karte
  # TODO: Nur wenn andere das Ausspielrecht haben nötig
  def karte_gefaerdet_auftrag(auftrag:, kommunizierbares:)
    moegliche_karten = @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe)
    if moegliche_karten.length.positive? && moegliche_karten.min.schlaegt?(auftrag.karte)
      min = moegliche_karten.min.wert
      kommunikation = kommunizierbares.min_by do |k|
        karte_gefaerdet_auftrag_k_wert(kommunikation: k, auftrag: auftrag)
      end
      SchimpanseKommunikation.new(
        kommunikation: kommunikation,
        prioritaet: (min - 7) * 100
      )
    else
      nicht_kommunizieren_kommunikation
    end
  end

  def keine_hohe_karte_kommunizieren(kommunizierbares)
    schimpansen_kommunikation = nicht_kommunizieren_kommunikation
    auftraege_von_mir = @spiel_informations_sicht.unerfuellte_auftraege[0]
    auftraege_von_mir.each do |auftrag|
      schimpansen_kommunikation.verbessere(
        auftrag_nicht_gedeckt_kommunizieren(auftrag: auftrag, kommunizierbares: kommunizierbares)
      )
    end
    schimpansen_kommunikation
  end

  def angepasste_floeten_laenge(laenge:, farbe:)
    karten = Karte.alle_mit_farbe(farbe)
    karten.reject { |karte| @spiel_informations_sicht.ist_gegangen?(karte) }
    (@spiel_informations_sicht.anzahl_spieler.to_f * laenge / karten.length) - 1
  end

  def lange_farbe_kommunizieren(auftrag:, kommunizierbares:)
    ziel_karte = @spiel_informations_sicht.karten.min
    laenge = 0
    Farbe::NORMALE_FARBEN.each do |farbe|
      next if farbe == auftrag.farbe

      karten = @spiel_informations_sicht.karten_mit_farbe(farbe)
      floeten_laenge = angepasste_floeten_laenge(laenge: karten.length, farbe: farbe)
      if floeten_laenge > laenge || (floeten_laenge == laenge && karten.max.wert > ziel_karte.wert)
        ziel_karte = karten.max
        laenge = floeten_laenge
      end
    end
    kommunikation = kommunizierbares.find do |moegliche_kommunikation|
      moegliche_kommunikation.karte == ziel_karte
    end
    SchimpanseKommunikation.new(kommunikation: kommunikation, prioritaet: laenge * 10)
  end

  def eigene_auftrags_farbe_unsicher_kommunizieren?(auftrag)
    karten = @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe)
    karten.delete_if do |karte|
      @spiel_informations_sicht.unerfuellte_auftraege[1..].flatten.any? do |auftrag_unerfuellt|
        auftrag_unerfuellt.karte == karte
      end
    end
    karten.length.zero? || karten.max.wert <= 5 || karten.max.wert < auftrag.karte.wert
  end

  def schwache_farbe_kommunizieren(auftrag:, kommunizierbares:)
    ziel_karte = @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe).max
    kommunikation = kommunizierbares.find do |moegliche_kommunikation|
      moegliche_kommunikation.karte == ziel_karte
    end
    SchimpanseKommunikation.new(kommunikation: kommunikation, prioritaet: AUFTRAG_NICHT_GEDECKT_PRIORITAET)
  end

  def auftrag_nicht_gedeckt_kommunizieren(auftrag:, kommunizierbares:)
    schimpansen_kommunikation = nicht_kommunizieren_kommunikation
    return schimpansen_kommunikation unless eigene_auftrags_farbe_unsicher_kommunizieren?(auftrag)

    schimpansen_kommunikation.verbessere(
      schwache_farbe_kommunizieren(auftrag: auftrag, kommunizierbares: kommunizierbares)
    )
    schimpansen_kommunikation.verbessere(
      trumpf_kommunizieren(_auftrag: auftrag, _kommunizierbares: kommunizierbares)
    )
    schimpansen_kommunikation
  end

  def blanker_auftrag_kommunizieren(kommunizierbares)
    schimpansen_kommunikation = nicht_kommunizieren_kommunikation
    Farbe::NORMALE_FARBEN.each do |farbe|
      schimpansen_kommunikation.verbessere(
        blanker_auftrag_mit_farbe_kommunizieren(kommunizierbares: kommunizierbares, farbe: farbe)
      )
    end
    schimpansen_kommunikation
  end

  def zwei_spieler_haben_auftraege_mit_farbe?(farbe:)
    anzahl_spieler = @spiel_informations_sicht.auftraege_mit_farbe(farbe).count do |auftraege|
      !auftraege.empty?
    end
    anzahl_spieler >= 2
  end

  def muss_blanken_auftrag_mit_karte_kommunizieren(farbe:)
    karten_mit_farbe = @spiel_informations_sicht.karten_mit_farbe(farbe)
    zwei_spieler_haben_auftraege_mit_farbe?(farbe: farbe) &&
      karten_mit_farbe.length == 1 &&
      @spiel_informations_sicht.auftraege.flatten.any? { |auftrag| karten_mit_farbe[0] == auftrag.karte }
  end

  def blanker_auftrag_mit_farbe_kommunizieren(kommunizierbares:, farbe:)
    return nicht_kommunizieren_kommunikation unless muss_blanken_auftrag_mit_karte_kommunizieren(farbe: farbe)

    kommunikation = kommunizierbares.find do |moegliche_kommunikation|
      moegliche_kommunikation.karte == @spiel_informations_sicht.karten_mit_farbe(farbe)[0]
    end
    SchimpanseKommunikation.new(kommunikation: kommunikation, prioritaet: BLANKER_AUFTRAG_PRIORITAET)
  end

  def trumpf_kommunizieren(_auftrag:, _kommunizierbares:)
    nicht_kommunizieren_kommunikation
  end

  def alles_super_kommunizieren(_kommunizierbares)
    nicht_kommunizieren_kommunikation
  end

  def karte_ist_auftrag_kommunizieren(_kommunizierbares)
    nicht_kommunizieren_kommunikation
  end

  def nicht_kommunizieren_kommunikation
    SchimpanseKommunikation.new(kommunikation: false, prioritaet: 0)
  end

  def waehle_kommunikation(kommunizierbares)
    schimpansen_kommunikation = nicht_kommunizieren_kommunikation
    schimpansen_kommunikation.verbessere(karte_gefaerdet_auftraege_kommunizieren(kommunizierbares))
    schimpansen_kommunikation.verbessere(blanker_auftrag_kommunizieren(kommunizierbares))
    schimpansen_kommunikation.verbessere(keine_hohe_karte_kommunizieren(kommunizierbares))
    schimpansen_kommunikation.verbessere(alles_super_kommunizieren(kommunizierbares))
    schimpansen_kommunikation.kommunikation
  end
end
