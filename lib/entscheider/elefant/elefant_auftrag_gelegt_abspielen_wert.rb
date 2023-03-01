# frozen_string_literal: true

# Wert vom Kartenlegen, wenn bereits ein Auftrag liegt
module ElefantAuftragGelegtAbspielenWert
  def auftrag_gelegt_abspielen_wert(stich:, karte:, spieler_index:, elefant_rueckgabe:)
    auftrag_von = karte_ist_auftrag_von(karte)
    if auftrag_von.nil?
      gelegten_auftrag_unterstuetzen_abspielen_wert(stich: stich, karte: karte,
                                                    spieler_index: spieler_index, elefant_rueckgabe: elefant_rueckgabe)
    elsif auftrag_von != spieler_index
      elefant_rueckgabe.symbol = :zweiten_auftrag_verboten_abspielen
      elefant_rueckgabe.wert = [-1, 0, 0, 0, 0]
    else
      kein_auftrag_gelegt_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def gelegten_auftrag_unterstuetzen_abspielen_wert(stich:, karte:, spieler_index:, elefant_rueckgabe:)
    if spieler_index.zero?
      elefant_rueckgabe.symbol = :eigenen_auftrag_holen_abspielen
      elefant_rueckgabe.wert = [0, 1, 0, karte.schlag_wert, 0]
    elsif karte.farbe == stich.staerkste_karte.farbe
      elefant_rueckgabe.symbol = :fremden_geholten_auftrag_unterbieten_abspielen
      elefant_rueckgabe.wert = [0, 1, 0, -karte.schlag_wert, 0]
    elsif karte.trumpf?
      elefant_rueckgabe.symbol = :fremden_auftrag_trumpfen_abspielen
      elefant_rueckgabe.wert = [0, 0, -1, -karte.schlag_wert, 0]
    else
      keine_auftrag_stich_farbe_andere_farbe_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    end
  end
end
