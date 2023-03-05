# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'gemeinsam/saeuger_auftrag_nehmer'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'
require_relative 'schimpanse/schimpanse_kommunizierender'
require_relative 'schimpanse/schimpanse_zeitdruck'
require_relative 'schimpanse/schimpanse_legen'

# Hangelt sich zwischen den Aufträgen durch
# Basiert auf Rhinoceros, aber ist weiterentwickelt
# und kann kommunizieren
class Schimpanse < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include SchimpanseLegen
  include SchimpanseKommunizierender
  include SpielInformationsSichtBenutzender
  include SchimpanseZeitdruck
end
