# coding: utf-8
# frozen_string_literal: true

require_relative 'schimpansen_lege_wert'

# Module für das Anspielen vom Rhinoceros
module SchimpanseAnspielen

  EIGENE_AUFTRAEGE_HOLEN_WERT_BASIS = 0.5
  
  def anspielen(waehlbare_karten)
    waehlbare_karten.max_by { |karte| anspiel_wert_karte(karte) }
  end

  def anspiel_wert_karte(karte)
    schimpansen_lege_wert = SchimpansenLegeWert.new(prioritaet: 0)
    eigenen_auftrag_holen_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    eigenen_auftrag_vermasseln_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    anderen_auftrag_geben_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    anderen_auftrag_vermasseln_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    selber_blank_machen_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    schimpansen_lege_wert
  end

  def eigenen_auftrag_holen_anspielen(schimpansen_lege_wert:, karte:)
    relevante_auftrag_zahl = eigene_auftraege.count {|auftrag|
      auftrag.farbe == karte.farbe &&
        auftrag.karte.wert < karte.wert &&
        karten.all? {|eigene_karte| eigene_karte != auftrag.karte}
    }
    schimpansen_lege_wert.warnung(-(1 - EIGENE_AUFTRAEGE_HOLEN_WERT_BASIS ** relevante_auftrag_zahl))
    schimpansen_lege_wert.warnung(-1) if eigene_auftraege.any? {|auftrag| auftrag.karte == karte}
  end
  
  def eigenen_auftrag_vermasseln_anspielen(schimpansen_lege_wert:, karte:)
  end
  
  def anderen_auftrag_geben_anspielen(schimpansen_lege_wert:, karte:)
  end

  def anderen_auftrag_vermasseln_anspielen(schimpansen_lege_wert:, karte:)
  end
  
  def selber_blank_machen_anspielen(schimpansen_lege_wert:, karte:)
  end
end
