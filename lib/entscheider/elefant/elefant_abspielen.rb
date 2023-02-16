# coding: utf-8
# frozen_string_literal: true

require_relative 'elefant_nuetzliches'
require_relative 'elefant_keinen_auftrag_abspielen_wert'

# gehört zu Elefant
# legt eine Karte auf einen Stich
module ElefantAbspielen
  include ElefantNuetzliches
  include ElefantKeinenAuftragAbspielenWert

  def abspielen(stich, waehlbare_karten)
    waehlbare_karten.max_by { |karte| abspielen_karten_wert(karte: karte, stich: stich) }
  end

  # wie gut eine Karte zum drauflegen geeignet ist
  def abspielen_karten_wert(karte:, stich:)
    spieler_index = finde_auftrag_in_stich(stich)
    if !spieler_index.nil?
      abspielen_auftrag_gelegt_wert(karte: karte, stich: stich, spieler_index: spieler_index)
    else
      abspielen_kein_auftrag_gelegt_wert(karte: karte, stich: stich)
    end
  end
  
  def abspielen_auftrag_gelegt_wert(karte:, stich:, spieler_index:)
    if spieler_index == 0
      karte.schlag_wert
    else
      -karte.schlag_wert
    end
  end

  def abspielen_kein_auftrag_gelegt_wert(karte:, stich:)
    karten_auftrag_index = karte_ist_auftrag_von(karte)
    if karten_auftrag_index.nil?
      keinen_auftrag_abspielen_wert(karte: karte, stich: stich)
    elsif karten_auftrag_index == 0
      eigenen_auftrag_abspielen_wert(karte: karte, stich: stich)
    else
      fremden_auftrag_abspielen_wert(karte: karte, stich: stich)
    end
  end

  def eigenen_auftrag_abspielen_wert(karte:, stich:)
    20
  end

  def fremden_auftrag_abspielen_wert(karte:, stich:)
    10
  end
end
