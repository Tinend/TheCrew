# frozen_string_literal: true

require 'spieler'
require 'karte'
require 'kommunikation'
require 'farbe'
require 'stich'
require 'spiel_information'
require 'entscheider/zufalls_entscheider'

RSpec.describe Spieler do
  subject(:spieler) do
    described_class.new(entscheider: ZufallsEntscheider.new,
                        spiel_informations_sicht: spiel_information.fuer_spieler(0))
  end

  let(:spiel_information) { SpielInformation.new(anzahl_spieler: 3) }
  let(:anderer_spieler) do
    described_class.new(entscheider: ZufallsEntscheider.new,
                        spiel_informations_sicht: spiel_information.fuer_spieler(1))
  end
  let(:roter_stich) do
    stich = Stich.new
    stich.legen(karte: Karte.new(farbe: Farbe::ROT, wert: 2), spieler: anderer_spieler)
    stich
  end

  let(:top_bottom_karten) do
    [
      Kommunikation.tiefste(Karte.new(farbe: Farbe::ROT, wert: 1)),
      Kommunikation.hoechste(Karte.new(farbe: Farbe::ROT, wert: 9)),
      Kommunikation.tiefste(Karte.new(farbe: Farbe::BLAU, wert: 1)),
      Kommunikation.hoechste(Karte.new(farbe: Farbe::BLAU, wert: 9)),
      Kommunikation.tiefste(Karte.new(farbe: Farbe::GELB, wert: 1)),
      Kommunikation.hoechste(Karte.new(farbe: Farbe::GELB, wert: 9)),
      Kommunikation.tiefste(Karte.new(farbe: Farbe::GRUEN, wert: 1)),
      Kommunikation.hoechste(Karte.new(farbe: Farbe::GRUEN, wert: 9))
    ]
  end

  it 'knows trumpf cannot be communicated' do
    spieler.bekomm_karten(Karte.alle_truempfe)
    expect(spieler.kommunizierbares).to be_empty
  end

  it 'knows top and bottom cards can be communicated' do
    spieler.bekomm_karten(Karte.alle)
    expect(spieler.kommunizierbares).to match_array(top_bottom_karten)
  end

  it 'knows unique cards can be communicated' do
    spieler.bekomm_karten([Karte.alle_normalen[0]])
    expect(spieler.kommunizierbares).to eq([Kommunikation.einzige(Karte.alle_normalen[0])])
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
