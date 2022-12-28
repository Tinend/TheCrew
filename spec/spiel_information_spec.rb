# frozen_string_literal: true

require 'spiel_information'

def auftrag(index)
  Karte.alle_normalen[index]
end

RSpec.describe(SpielInformation) do
  subject(:spiel_information) { described_class.new(anzahl_spieler: 3) }

  it 'tells a player the right tasks' do
    sicht = spiel_information.fuer_spieler(1)
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: auftrag(0))
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: auftrag(1))
    spiel_information.auftrag_gewaehlt(spieler_index: 1, auftrag: auftrag(10))
    spiel_information.auftrag_gewaehlt(spieler_index: 2, auftrag: auftrag(20))

    auftraege = sicht.auftraege
    expect(auftraege[0]).to eq([auftrag(10)])
    expect(auftraege[1]).to eq([auftrag(20)])
    expect(auftraege[2]).to eq([auftrag(0), auftrag(1)])
  end

  it 'tells a captain that they are the capitain' do
    sicht = spiel_information.fuer_spieler(1)
    spiel_information.setze_kapitaen(1)
    expect(sicht.kapitaen).to eq(0)
  end

  it 'tells a captain that their next neightbor is the capitain' do
    sicht = spiel_information.fuer_spieler(2)
    spiel_information.setze_kapitaen(0)
    expect(sicht.kapitaen).to eq(1)
  end

  it 'tells a captain that their previous neighbor is the capitain' do
    sicht = spiel_information.fuer_spieler(1)
    spiel_information.setze_kapitaen(0)
    expect(sicht.kapitaen).to eq(2)
  end
end
