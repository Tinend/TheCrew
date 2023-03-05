# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'gemeinsam/saeuger_auftrag_nehmer'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'
require_relative 'gemeinsam/zufalls_kommunizierender'

# Aufträge: Wenn er ihn hat, bevorzugt groß, wenn er ihn nicht hat, bevorzugt tief
# Grundlage für die meisten Entscheider mit Tiernamen
class Saeuger < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include ZufallsKommunizierender

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample(random: @zufalls_generator)
  end
end
