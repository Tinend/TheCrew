# frozen_string_literal: true

require 'spieler'
require 'karte'
require 'farbe'
require 'stich'
require 'entscheider/zufalls_entscheider'

RSpec.describe Spieler do
  subject { Spieler.new(ZufallsEntscheider.new) }
  let(:anderer_spieler) { Spieler.new(ZufallsEntscheider.new) }
  let(:roter_stich) do
    stich = Stich.new
    stich.legen(karte: Karte.new(farbe: Farbe::ROT, wert: 2), spieler: anderer_spieler)
    stich
  end

  it 'knows if it begins' do
    subject.bekomm_karten(Karte.alle_truempfe)
    expect(subject.faengt_an?).to be(true)
  end

  it 'knows if it does not begin' do
    subject.bekomm_karten(Karte.alle_normalen)
    expect(subject.faengt_an?).to be(false)
  end

  it 'knows when only red cards can be played' do
    subject.bekomm_karten(Karte.alle_normalen)
    expect(subject.waehle_karte(roter_stich).farbe) == Farbe::ROT
  end
end
