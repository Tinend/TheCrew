# coding: utf-8
# frozen_string_literal: true

# Berechnet, wie gut eine Karte zum Anspielen ist,
# wenn mehrere Spieler Aufträge von dieser Farbe hat,
# aber sie selber kein Auftrag ist
module ElefantMultipleAuftragFarbeAnspielenWert
  # rubocop:disable Lint/UnusedMethodArgument
  def multiple_auftrag_farbe_anspielen_wert(karte:, auftraege_mit_farbe:)
    spieler_index = will_blanken_auftrag(farbe: karte.farbe)
    if spieler_index.nil?
      eigene_auftrag_farbe_anspielen_wert(karte: karte)
    else
      fremden_auftrag_farbe_anspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe)
    end
  end

  def will_blanken_auftrag(farbe:)
    @spiel_informations_sicht.kommunikationen.each_with_index do |kommunikation, spieler_index|
      if kommunikation != nil && spieler_index != 0 && kommunikation.art == :einzige &&
         kommunikation.karte.farbe == farbe &&
         !@spiel_informations_sicht.ist_gegangen?(kommunikation.karte)
        return spieler_index
      end
    end
    nil
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
