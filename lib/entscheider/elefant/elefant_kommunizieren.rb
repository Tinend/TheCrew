# frozen_string_literal: true

require_relative 'elefant_kommunikation'

# handelt die Kommunikation vom Elefanten
module ElefantKommunizieren
  def waehle_kommunikation(kommunizierbares)
    elefant_kommunikation = nicht_kommunizieren_kommunikation
    elefant_kommunikation.verbessere(karte_gefaerdet_auftraege_kommunizieren(kommunizierbares))
  end

  def karte_gefaerdet_auftraege_kommunizieren(kommunizierbares)
    elefant_kommunikation = nicht_kommunizieren_kommunikation
    auftraege_von_anderen = @spiel_informations_sicht.unerfuellte_auftraege[1..].flatten
    auftraege_von_anderen.each do |auftrag|
      elefant_kommunikation.verbessere(
        karte_gefaerdet_auftrag(auftrag: auftrag, kommunizierbares: kommunizierbares)
      )
    end
    elefant_kommunikation
  end

  def karte_gefaerdet_auftrag_k_wert(kommunikation:, auftrag:)
    return 100 if kommunikation.karte.farbe != auftrag.farbe

    kommunikation.karte.wert
  end

  def karte_gefaerdet_auftrag(auftrag:, kommunizierbares:)
    moegliche_karten = @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe)
    if !moegliche_karten.empty? && moegliche_karten.min.schlaegt?(auftrag.karte)
      min = moegliche_karten.min.wert
      kommunikation = kommunizierbares.min_by do |k|
        karte_gefaerdet_auftrag_k_wert(kommunikation: k, auftrag: auftrag)
      end
      ElefantKommunikation.new(
        kommunikation: kommunikation,
        prioritaet: (min - 7) * 100
      )
    else
      nicht_kommunizieren_kommunikation
    end
  end

  def nicht_kommunizieren_kommunikation
    ElefantKommunikation.new(kommunikation: false, prioritaet: 0)
  end
end
