# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'saeuger_auftrag_nehmer'
require_relative 'spiel_informations_sicht_benutzender'
require_relative 'elefant/elefant_abspielen'
require_relative 'elefant/elefant_anspielen'
require_relative 'elefant/elefant_kommunizieren'
require_relative 'bakterie/bakterie_kommunizierender'

# Rennt geradewegs auf die Aufträge zu
# Geht 100 Fälle durch und wählt geeigneten aus
class Elefant < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include ElefantAbspielen
  include ElefantAnspielen
  # include ElefantKommunizieren
  include BakterieKommunizierender

  def waehle_karte(stich, waehlbare_karten)
    if stich.karten.empty?
      anspielen(waehlbare_karten)
    else
      abspielen(stich, waehlbare_karten)
    end
  end

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end
end
