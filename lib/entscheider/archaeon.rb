# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'gemeinsam/zufalls_kommunizierender'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'

# Entscheider, der immer die erste Karte wählt.
# Auf den ersten Blick gleich wie der ZufallsEntscheider.
# Tatsächlich spielt er weniger gerne Farben die er bereits gespielt hat.
class Archaeon < Entscheider
  include ZufallsKommunizierender
  include SpielInformationsSichtBenutzender

  def waehl_auftrag(auftraege)
    auftraege[0]
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten[0]
  end
end
