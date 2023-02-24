# coding: utf-8
# frozen_string_literal: true

require_relative 'elefant_nuetzliches'
require_relative 'elefant_keinen_auftrag_abspielen_wert'
require_relative 'elefant_fremden_auftrag_abspielen_wert'
require_relative 'elefant_eigenen_auftrag_abspielen_wert'
require_relative 'elefant_auftrag_gelegt_abspielen_wert'

# gehört zu Elefant
# legt eine Karte auf einen Stich
module ElefantAbspielen
  include ElefantNuetzliches
  include ElefantKeinenAuftragAbspielenWert
  include ElefantFremdenAuftragAbspielenWert
  include ElefantEigenenAuftragAbspielenWert
  include ElefantAuftragGelegtAbspielenWert

  def abspielen(stich, waehlbare_karten)
    # waehlbare_karten.max_by { |karte| x = abspielen_wert(karte: karte, stich: stich); puts karte; p x}
    waehlbare_karten.max_by { |karte| abspielen_wert(karte: karte, stich: stich) }
  end

  # wie gut eine Karte zum drauflegen geeignet ist
  def abspielen_wert(karte:, stich:)
    spieler_index = finde_auftrag_in_stich(stich)
    if spieler_index.nil?
      kein_auftrag_gelegt_abspielen_wert(karte: karte, stich: stich)
    else
      auftrag_gelegt_abspielen_wert(stich: stich, karte: karte, spieler_index: spieler_index)
    end
  end

  def kein_auftrag_gelegt_abspielen_wert(karte:, stich:)
    karten_auftrag_index = karte_ist_auftrag_von(karte)
    if karten_auftrag_index.nil?
      keinen_auftrag_abspielen_wert(karte: karte, stich: stich)
    elsif karten_auftrag_index.zero?
      eigenen_auftrag_abspielen_wert(karte: karte, stich: stich)
    else
      fremden_auftrag_abspielen_wert(karte: karte, stich: stich, ziel_spieler_index: karten_auftrag_index)
    end
  end
end
