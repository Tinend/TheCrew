# frozen_string_literal: true

require 'entscheider/ai_input_ersteller'
require 'spiel_information'
require 'karte'

RSpec.describe AiInputErsteller do
  subject(:ai_input_ersteller) { described_class.new }
  let(:anzahl_spieler) { 5 }
  let(:spiel_information) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[], [Karte.max_trumpf], [], [], []])
    spiel_information
  end
  let(:spiel_informations_sicht) { spiel_information.fuer_spieler(0) }

  it 'hat die vorhergesagte laenge' do
    expect(ai_input_ersteller.input(spiel_informations_sicht).length).to eq(ai_input_ersteller.input_laenge)
  end
end
