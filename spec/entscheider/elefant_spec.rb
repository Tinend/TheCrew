# coding: utf-8

require 'entscheider/elefant'
require 'karte'
require 'farbe'
require 'stich'
require 'spieler'
require 'spiel_information'
require 'auftrag'

RSpec.describe Elefant do
  subject(:elefant) do
    elefant = described_class.new(zufalls_generator: Random.new(42))
    elefant.sehe_spiel_informations_sicht(spiel_informations_sicht)
    elefant
  end
  let(:anzahl_spieler) { 5 }
  let(:spiel_information) { SpielInformation.new(anzahl_spieler: anzahl_spieler) }
  let(:spiel_informations_sicht) { spiel_information.fuer_spieler(0) }
  let(:leerer_stich) { Stich.new }
  let(:leere_stich_sicht) { leerer_stich.fuer_spieler(spieler_index: 0, anzahl_spieler: anzahl_spieler) }
  let(:spieler) { Spieler.new(entscheider: elefant, spiel_informations_sicht: spiel_informations_sicht) }
  let(:gruene_drei) { Karte.new(farbe: Farbe::GRUEN, wert: 3) }
  let(:gruene_drei_auftrag) { auftrag = Auftrag.new(gruene_drei); auftrag.aktivieren; auftrag }
  let(:rote_neun) { Karte.new(farbe: Farbe::ROT, wert: 9) }
  let(:rote_neun_auftrag) { auftrag = Auftrag.new(rote_neun); auftrag.aktivieren; auftrag }
  let(:rote_acht) { Karte.new(farbe: Farbe::ROT, wert: 8) }
  let(:rote_sieben) { Karte.new(farbe: Farbe::ROT, wert: 7) }
  let(:rote_sechs) { Karte.new(farbe: Farbe::ROT, wert: 6) }
  let(:rote_sechs_auftrag) { auftrag = Auftrag.new(rote_sechs); auftrag.aktivieren; auftrag }
  let(:rote_fuenf) { Karte.new(farbe: Farbe::ROT, wert: 5) }
  let(:rote_fuenf_auftrag) { auftrag = Auftrag.new(rote_fuenf); auftrag.aktivieren; auftrag }
  let(:rote_vier) { Karte.new(farbe: Farbe::ROT, wert: 4) }
  let(:rote_drei) { Karte.new(farbe: Farbe::ROT, wert: 3) }
  let(:rote_drei_auftrag) { auftrag = Auftrag.new(rote_drei); auftrag.aktivieren; auftrag }
  let(:rote_zwei) { Karte.new(farbe: Farbe::ROT, wert: 2) }
  let(:rote_eins) { Karte.new(farbe: Farbe::ROT, wert: 1) }
  let(:rote_eins_auftrag) { auftrag = Auftrag.new(rote_eins); auftrag.aktivieren; auftrag }
  let(:gelbe_drei) { Karte.new(farbe: Farbe::GELB, wert: 3) }
  let(:neun_stich) do
    stich = Stich.new
    stich.legen(karte: rote_neun, spieler_index: 4)
    stich
  end
  let(:neun_stich_sicht) {neun_stich.fuer_spieler(spieler_index: 0, anzahl_spieler: anzahl_spieler)}
  let(:gelbe_drei_stich) do
    stich = Stich.new
    stich.legen(karte: gelbe_drei, spieler_index: 4)
    stich
  end
  let(:gelbe_drei_stich_sicht) {gelbe_drei_stich.fuer_spieler(spieler_index: 0, anzahl_spieler: anzahl_spieler)}

  it "Wählt einzige wählbare Karte" do
    spiel_information.verteil_karten([[gruene_drei], [Karte.max_trumpf], [], [], []])
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(gruene_drei)
  end

  it "Spielt die rote Neun, die der eigene Auftrag ist" do
    spiel_information.verteil_karten([[gruene_drei, rote_neun], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_neun_auftrag)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(rote_neun)
  end

  it "Schmiert die rote sechs in einen Stich mit der roten neun" do
    spiel_information.verteil_karten([[rote_drei, rote_sechs], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 1, auftrag: rote_sechs_auftrag)
    karte = spieler.waehle_karte(neun_stich_sicht)
    expect(karte).to eq(rote_sechs)
  end

  it "Wirft nicht den eigenen Auftrag rein" do
    spiel_information.verteil_karten([[rote_drei, rote_sechs], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_sechs_auftrag)
    karte = spieler.waehle_karte(neun_stich_sicht)
    expect(karte).to eq(rote_drei)
  end

  it "Schmiert nicht den eigenen Auftrag rein" do
    spiel_information.verteil_karten([[gruene_drei, rote_sechs], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_sechs_auftrag)
    karte = spieler.waehle_karte(gelbe_drei_stich_sicht)
    expect(karte).to eq(gruene_drei)
  end

  it "Spielt keine eigenen tiefen Auftrag an" do
    spiel_information.verteil_karten([[gruene_drei, rote_fuenf], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_fuenf_auftrag)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(gruene_drei)
  end

  it "Spielt eigene hohe Auftraege an" do
    spiel_information.verteil_karten([[gruene_drei, rote_sechs], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_sechs_auftrag)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(rote_sechs)
  end

  it "Spielt eigene tiefe Auftraege an, wenn alle höheren gegangen sind" do
    spiel_information.verteil_karten([[gruene_drei, rote_eins], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_eins_auftrag)
    stich1 = Stich.new
    [rote_zwei, rote_drei, rote_vier, rote_fuenf].each_with_index {|karte, index| stich1.legen(karte: karte, spieler_index: index)}
    spiel_information.stich_fertig(stich1)
    stich2 = Stich.new
    [rote_sechs, rote_sieben, rote_acht, rote_neun].each_with_index {|karte, index| stich2.legen(karte: karte, spieler_index: index)}
    spiel_information.stich_fertig(stich2)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(rote_eins)
  end

  it "Spielt eigene tiefe Auftraege an, wenn alle höheren gegangen oder auf der Hand sind" do
    spiel_information.verteil_karten([[gruene_drei, rote_eins, rote_neun], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_eins_auftrag)
    stich1 = Stich.new
    [rote_zwei, rote_drei, rote_vier, rote_fuenf].each_with_index {|karte, index| stich1.legen(karte: karte, spieler_index: index)}
    spiel_information.stich_fertig(stich1)
    stich2 = Stich.new
    [rote_sechs, rote_sieben, rote_acht, gelbe_drei].each_with_index {|karte, index| stich2.legen(karte: karte, spieler_index: index)}
    spiel_information.stich_fertig(stich2)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(rote_eins)
  end

  it "Spielt fremden Auftrag an" do
    spiel_information.verteil_karten([[gruene_drei, rote_sechs], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 1, auftrag: rote_sechs_auftrag)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(rote_sechs)
  end

  it "Spielt lieber hohen eigenen Auftrag als fremden Auftrag an" do
    spiel_information.verteil_karten([[gruene_drei, rote_neun], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_neun_auftrag)
    spiel_information.auftrag_gewaehlt(spieler_index: 1, auftrag: gruene_drei_auftrag)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(rote_neun)
  end

  it "Holt lieber eigenen Auftrag mit hoher Karte als fremden Auftrag anspielen" do
    spiel_information.verteil_karten([[gruene_drei, rote_neun], [Karte.max_trumpf], [], [], []])
    spiel_information.auftrag_gewaehlt(spieler_index: 0, auftrag: rote_sechs_auftrag)
    spiel_information.auftrag_gewaehlt(spieler_index: 1, auftrag: gruene_drei_auftrag)
    karte = spieler.waehle_karte(leere_stich_sicht)
    expect(karte).to eq(rote_neun)
  end
end
