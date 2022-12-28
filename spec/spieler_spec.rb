# frozen_string_literal: true

require 'spieler'
require 'karte'
require 'farbe'
require 'stich'
require 'spiel_information'
require 'entscheider/zufalls_entscheider'

RSpec.describe Spieler do
  subject(:spieler) { described_class.new(entscheider: ZufallsEntscheider.new, spiel_informations_sicht: spiel_information.fuer_spieler(0)) }

  let(:spiel_information) { SpielInformation.new(anzahl_spieler: 3) }
  let(:anderer_spieler) { described_class.new(entscheider: ZufallsEntscheider.new, spiel_informations_sicht: spiel_information.fuer_spieler(1)) }
  let(:roter_stich) do
    stich = Stich.new
    stich.legen(karte: Karte.new(farbe: Farbe::ROT, wert: 2), spieler: anderer_spieler)
    stich
  end

  it 'knows if it begins' do
    spieler.bekomm_karten(Karte.alle_truempfe)
    expect(spieler.faengt_an?).to be(true)
  end

  it 'knows if it does not begin' do
    spieler.bekomm_karten(Karte.alle_normalen)
    expect(spieler.faengt_an?).to be(false)
  end

  it 'knows when only red cards can be played' do
    spieler.bekomm_karten(Karte.alle_normalen)
    expect(spieler.waehle_karte(roter_stich).farbe) == Farbe::ROT
  end
end
