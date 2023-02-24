# frozen_string_literal: true

# Wert vom Kartenlegen, wenn bereits ein Auftrag liegt
module ElefantAuftragGelegtAbspielenWert
  def auftrag_gelegt_abspielen_wert(stich:, karte:, spieler_index:)
    auftrag_von = karte_ist_auftrag_von(karte)
    if auftrag_von.nil?
      gelegten_auftrag_unterstuetzen_abspielen_wert(stich: stich, karte: karte, spieler_index: spieler_index)
    elsif auftrag_von != spieler_index
      [-1, 0, 0, 0, 0]
    else
      kein_auftrag_gelegt_abspielen_wert(karte: karte, stich: stich)
    end
  end

  def gelegten_auftrag_unterstuetzen_abspielen_wert(stich:, karte:, spieler_index:)
    if spieler_index.zero?
      [0, 1, 0, karte.schlag_wert, 0]
    elsif karte.farbe == stich.staerkste_karte.farbe
      [0, 1, 0, -karte.schlag_wert, 0]
    elsif karte.trumpf?
      [0, 0, -1, -karte.schlag_wert, 0]
    else
      keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte: karte)
    end
  end
end
