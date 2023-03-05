# frozen_string_literal: true

require 'entscheider/q_learning_entscheider/ai_input_ersteller'
require 'spiel_information'
require 'karte'

RSpec.describe AiInputErsteller do
  let(:anzahl_spieler) { 5 }
  let(:spiel_information) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[], [Karte.max_trumpf], [], [], []])
    spiel_information
  end
  let(:andere_spielerzahl_spiel_informations_sicht) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler - 1)
    spiel_information.verteil_karten([[], [Karte.max_trumpf], [], []])
    spiel_information.fuer_spieler(0)
  end
  let(:anderer_kapitaen_spiel_informations_sicht) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[], [], [Karte.max_trumpf], [], []])
    spiel_information.fuer_spieler(0)
  end
  let(:andere_handkarten_spiel_informations_sicht) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[Karte.alle_normalen.first], [], [Karte.max_trumpf], [], []])
    spiel_information.fuer_spieler(0)
  end
  let(:andere_anzahl_karten_spiel_informations_sicht) do
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spiel_information.verteil_karten([[], [Karte.alle_normalen.first], [Karte.max_trumpf], [], []])
    spiel_information.fuer_spieler(0)
  end
  let(:spiel_informations_sicht) { spiel_information.fuer_spieler(0) }
  let(:ai_input) { described_class.ai_input(spiel_informations_sicht, :kommunikation) }

  it 'hat die vorhergesagte laenge' do
    expect(ai_input.input_array.length).to eq(described_class.ai_input_laenge)
  end

  it 'sieht anders aus mit anderer Spielerzahl' do
    anderer_ai_input = described_class.ai_input(andere_spielerzahl_spiel_informations_sicht, :kommunikation)
    expect(ai_input).not_to eq(anderer_ai_input)
  end

  it 'sieht anders aus mit anderem Kapitän' do
    anderer_ai_input = described_class.ai_input(anderer_kapitaen_spiel_informations_sicht, :kommunikation)
    expect(ai_input).not_to eq(anderer_ai_input)
  end

  it 'sieht anders aus mit anderen Handkarten' do
    anderer_ai_input = described_class.ai_input(andere_handkarten_spiel_informations_sicht, :kommunikation)
    expect(ai_input).not_to eq(anderer_ai_input)
  end

  it 'sieht anders aus mit anderen Anzahl Karten' do
    anderer_ai_input = described_class.ai_input(andere_anzahl_karten_spiel_informations_sicht, :kommunikation)
    expect(ai_input).not_to eq(anderer_ai_input)
  end

  it 'sieht anders aus mit anderer Aktion' do
    anderer_ai_input = described_class.ai_input(spiel_informations_sicht, :karte)
    expect(ai_input).not_to eq(anderer_ai_input)
  end

  it 'sieht anders aus mit noch anderer Aktion' do
    anderer_ai_input = described_class.ai_input(spiel_informations_sicht, :auftrag)
    expect(ai_input).not_to eq(anderer_ai_input)
  end

  it 'sieht anders aus mit noch noch anderer Aktion' do
    ai_input = described_class.ai_input(spiel_informations_sicht, :karte)
    anderer_ai_input = described_class.ai_input(spiel_informations_sicht, :auftrag)
    expect(ai_input).not_to eq(anderer_ai_input)
  end
end
