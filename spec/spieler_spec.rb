# frozen_string_literal: true

require 'spieler'
require 'karte'
require 'kommunikation'
require 'farbe'
require 'stich'
require 'spiel_information'
require 'entscheider/zufalls_entscheider'
require 'statistiker'

RSpec.describe Spieler do
  subject(:spieler) do
    described_class.new(entscheider: entscheider,
                        spiel_informations_sicht: spiel_information.fuer_spieler(0))
  end

  let(:entscheider) do
    ZufallsEntscheider.new(zufalls_generator: Random.new(42), zaehler_manager: Statistiker.new.neuer_zaehler_manager)
  end
  let(:spiel_information) { SpielInformation.new(anzahl_spieler: 3) }
  let(:roter_stich) do
    stich = Stich.new
    stich.legen(karte: Karte.new(farbe: Farbe::ROT, wert: 2), spieler_index: 2)
    stich
  end
  let(:roter_stich_sicht) do
    roter_stich.fuer_spieler(spieler_index: 0, anzahl_spieler: 3)
  end
  let(:top_bottom_karten) do
    [
      Kommunikation.tiefste(karte: Karte.new(farbe: Farbe::ROT, wert: 1), gegangene_stiche: 0),
      Kommunikation.hoechste(karte: Karte.new(farbe: Farbe::ROT, wert: 9), gegangene_stiche: 0),
      Kommunikation.tiefste(karte: Karte.new(farbe: Farbe::BLAU, wert: 1), gegangene_stiche: 0),
      Kommunikation.hoechste(karte: Karte.new(farbe: Farbe::BLAU, wert: 9), gegangene_stiche: 0),
      Kommunikation.tiefste(karte: Karte.new(farbe: Farbe::GELB, wert: 1), gegangene_stiche: 0),
      Kommunikation.hoechste(karte: Karte.new(farbe: Farbe::GELB, wert: 9), gegangene_stiche: 0),
      Kommunikation.tiefste(karte: Karte.new(farbe: Farbe::GRUEN, wert: 1), gegangene_stiche: 0),
      Kommunikation.hoechste(karte: Karte.new(farbe: Farbe::GRUEN, wert: 9), gegangene_stiche: 0)
    ]
  end
  let(:irgendeine_karte) { Karte.alle_normalen.first }
  let(:irgendeine_einzige) { Kommunikation.einzige(karte: irgendeine_karte, gegangene_stiche: 0) }

  it 'knows trumpf cannot be communicated' do
    spiel_information.verteil_karten([Karte.alle_truempfe, [], []])
    expect(spieler.waehlbare_kommunikationen).to be_empty
  end

  it 'knows top and bottom cards can be communicated' do
    spiel_information.verteil_karten([Karte.alle, [], []])
    expect(spieler.waehlbare_kommunikationen).to match_array(top_bottom_karten)
  end

  it 'knows unique cards can be communicated' do
    spiel_information.verteil_karten([[irgendeine_karte], [], []])
    expect(spieler.waehlbare_kommunikationen).to eq([irgendeine_einzige])
  end

  it 'knows when only red cards can be played' do
    spiel_information.verteil_karten([Karte.alle_normalen, [], []])
    expect(spieler.waehle_karte(roter_stich_sicht).farbe) == Farbe::ROT
  end
end
