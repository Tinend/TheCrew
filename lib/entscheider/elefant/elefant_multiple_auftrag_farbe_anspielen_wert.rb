# coding: utf-8
# frozen_string_literal: true

# Berechnet, wie gut eine Karte zum Anspielen ist,
# wenn mehrere Spieler Aufträge von dieser Farbe hat,
# aber sie selber kein Auftrag ist
module ElefantMultipleAuftragFarbeAnspielenWert
  def multiple_auftrag_farbe_anspielen_wert(karte:, auftraege_mit_farbe:, elefant_rueckgabe:)
    spieler_index = will_blanken_auftrag(farbe: karte.farbe)
    if spieler_index == :tod
      elefant_rueckgabe.symbol = :multiple_blanke_auftraege_verboten_anspielen
      elefant_rueckgabe.wert = [-1, 0, 0, 0, 0]
    elsif spieler_index.nil? || spieler_index.zero?
      eigene_auftrag_farbe_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    else
      fremden_auftrag_farbe_anspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe,
                                           elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def will_blanken_auftrag(farbe:)
    spieler_index = nil
    @spiel_informations_sicht.kommunikationen.each_with_index do |kommunikation, index|
      next unless index != 0 &&
                  einzige_farbkorrekte_aktive_kommunikation?(kommunikation: kommunikation, farbe: farbe)

      neuer_spieler_index = karte_ist_auftrag_von(kommunikation.karte)
      next if neuer_spieler_index.nil?
      return :tod unless spieler_index.nil?

      spieler_index = neuer_spieler_index
    end
    spieler_index
  end

  def einzige_farbkorrekte_aktive_kommunikation?(kommunikation:, farbe:)
    !kommunikation.nil? && kommunikation.art == :einzige &&
      kommunikation.karte.farbe == farbe &&
      !@spiel_informations_sicht.ist_gegangen?(kommunikation.karte)
  end
end
