# frozen_string_literal: true

require 'entscheider/ai_input_erstellender'
require 'spiel_information'
require 'karte'

class AiInputBenutzer
  include AiInputErstellender
end

RSpec.describe AiInputErstellender do
  subject(:ai_input_benutzer) { AiInputBenutzer.new }
  let(:anzahl_spieler) { 5 }
  let(:spiel_information) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[], [Karte.max_trumpf], [], [], []])
    spiel_information
  end
  let(:spiel_informations_sicht) { spiel_information.fuer_spieler(0) }

  it 'hat die vorhergesagte laenge' do
    expect(ai_input_benutzer.spiel_informations_sicht_zu_input(spiel_informations_sicht).length).to eq(ai_input_benutzer.input_laenge)
  end
end
