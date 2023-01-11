# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'saeuger_auftrag_nehmer'
require_relative 'spiel_informations_sicht_benutzender'
require_relative 'rhinoceros_abspielen'
require_relative 'schimpanse_anspielen'
require_relative 'schimpanse_kommunizierender'
require_relative 'schimpanse_karten_wert'
require_relative 'spiel_informations_sicht_benutzender'

# Hangelt sich zwischen den Aufträgen durch
# Basiert auf Rhinoceros, aber ist weiterentwickelt
# und kann kommunizieren
class Schimpanse < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include RhinocerosAbspielen
  include SchimpanseAnspielen
  include SchimpanseKommunizierender
  include SpielInformationsSichtBenutzender

  def waehle_karte(stich, waehlbare_karten)
    if stich.karten.length.zero?
      anspielen(waehlbare_karten)
    else
      abspielen(stich, waehlbare_karten)
    end
  end
end
