# coding: utf-8
# frozen_string_literal: true

require_relative 'schimpanse_kommunikation'

# Modul für Schimpanse-Kommunikation
module SchimpanseKommunizierender
  def karte_gefaerdet_auftraege_kommunizieren(kommunizierbares)
    schimpansen_kommunikation = SchimpanseKommunikation.new(kommunikation: false, prioritaet: 0)
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
  def karte_gefaerdet_auftrag(auftrag:, kommunizierbares:)
    moegliche_karten = @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe)
    if moegliche_karten.length > 0 && moegliche_karten.min.schlaegt?(auftrag.karte) &&
       moegliche_karten.min.wert >= 8
      min = moegliche_karten.min.wert
      kommunikation = kommunizierbares.min_by {|k|
        karte_gefaerdet_auftrag_k_wert(kommunikation: k, auftrag: auftrag)
      }
      SchimpanseKommunikation.new(
        kommunikation: kommunikation,
        prioritaet: min * 100
      )
    else
      SchimpanseKommunikation.new(kommunikation: false, prioritaet: 0)
    end
  end

  def keine_hohe_karte_kommunizieren(kommunizierbares)
    schimpansen_kommunikation = SchimpanseKommunikation.new(kommunikation: false, prioritaet: 0)
  end
 
  def alles_super_kommunizieren(kommunizierbares)
    schimpansen_kommunikation = SchimpanseKommunikation.new(kommunikation: false, prioritaet: 0)
  end

  def waehle_kommunikation(kommunizierbares)
    schimpansen_kommunikation = karte_gefaerdet_auftraege_kommunizieren(kommunizierbares)
    schimpansen_kommunikation.verbessere(keine_hohe_karte_kommunizieren(kommunizierbares))
    schimpansen_kommunikation.verbessere(alles_super_kommunizieren(kommunizierbares))
    schimpansen_kommunikation.kommunikation
  end
end
