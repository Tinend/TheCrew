# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'
require_relative 'bakterie/bakterie_kommunizierender'

# Hangelt sich zwischen den Aufträgen durch
# Basiert auf Rhinoceros, aber ist weiterentwickelt
# und kann kommunizieren
class Bakterie < Entscheider
  include SpielInformationsSichtBenutzender
  include BakterieKommunizierender

  def waehl_auftrag(auftraege)
    auftraege.sample(random: @zufalls_generator)
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample(random: @zufalls_generator)
  end
end
