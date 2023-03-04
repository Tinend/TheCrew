# frozen_string_literal: true

require 'entscheider/ai_input_ersteller'
require 'spiel_information'
require 'karte'

RSpec.describe AiInputErsteller do
  let(:anzahl_spieler) { 5 }
  let(:spiel_information) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[], [Karte.max_trumpf], [], [], []])
    spiel_information
  end
  let(:andere_spielerzahl_spiel_information) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[], [Karte.max_trumpf], [], [], []])
    spiel_information
  end
  let(:spiel_informations_sicht) { spiel_information.fuer_spieler(0) }

  it 'hat die vorhergesagte laenge' do
    expect(described_class.ai_input(spiel_informations_sicht,
                                    :kommunikation).length).to eq(described_class.ai_input_laenge)
  end
end
