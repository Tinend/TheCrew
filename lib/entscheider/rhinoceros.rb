# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'gemeinsam/saeuger_auftrag_nehmer'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'
require_relative 'rhinoceros/rhinoceros_abspielen'
require_relative 'rhinoceros/rhinoceros_anspielen'

# Rennt geradewegs auf die Aufträge zu
# Geht 100 Fälle durch und wählt geeigneten aus
class Rhinoceros < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include RhinocerosAbspielen
  include RhinocerosAnspielen

  def waehle_karte(stich, waehlbare_karten)
    if stich.karten.empty?
      anspielen(waehlbare_karten)
    else
      abspielen(stich, waehlbare_karten)
    end
  end
end
