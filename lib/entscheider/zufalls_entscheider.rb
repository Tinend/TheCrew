# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'spiel_informations_sicht_benutzender'
require_relative 'zufalls_kommunizierender'

# Entscheider, der immer zufällig entschiedet, was er spielt.
class ZufallsEntscheider < Entscheider
  include SpielInformationsSichtBenutzender
  include ZufallsKommunizierender

  def waehl_auftrag(auftraege)
    auftraege.sample(random: @zufalls_generator)
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample(random: @zufalls_generator)
  end
end
