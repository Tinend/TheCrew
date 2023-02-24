# coding: utf-8
# frozen_string_literal: true

require_relative 'elefant_nuetzliches'
require_relative 'elefant_keinen_auftrag_anspielen_wert'

# Module für das Anspielen vom Elefant
module ElefantAnspielen
  include ElefantNuetzliches
  include ElefantKeinenAuftragAnspielenWert

  def anspielen(waehlbare_karten)
    waehlbare_karten.max_by { |karte| anspielen_wert(karte) }
  end

  # wie gut eine Karte zum Anspielen geeignet ist
  def anspielen_wert(karte)
    karten_auftrag_index = karte_ist_auftrag_von(karte)
    if karten_auftrag_index.nil?
      keinen_auftrag_anspielen_wert(karte)
    elsif karten_auftrag_index.zero?
      eigenen_auftrag_anspielen_wert(karte)
    else
      fremden_auftrag_anspielen_wert(karte: karte, auftrag_index: karten_auftrag_index)
    end
  end

  def eigenen_auftrag_anspielen_wert(karte)
    if jeder_kann_unterbieten?(karte: karte)
      [0, 1, 4, karte.wert, 0]
    else
      [0, -1, 0, 0, 0]
    end
  end

  def fremden_auftrag_anspielen_wert(karte:, auftrag_index:)
    if ist_blank_auf_farbe?(farbe: karte.farbe, spieler_index: auftrag_index) ||
       kann_ueberbieten?(karte: karte, spieler_index: auftrag_index)
      [0, 1, 1, 0, 0]
    else
      [0, -1, -1, 0, 0]
    end
  end

  def ist_blank_auf_farbe?(farbe:, spieler_index:)
    @spiel_informations_sicht.moegliche_karten(spieler_index).all? do |moegliche_karte|
      moegliche_karte.farbe != farbe
    end
  end
end
