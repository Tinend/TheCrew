require 'entscheider/reinwerfer'
require 'spieler'
require 'karte'
require 'auftrag'
require 'farbe'

def lass_reinwerfer_karte_waehlen(spieler, spiel_information, karten, stich_sicht)
  # Wenn der Spieler die schwarze 4 nicht kriegt, geben wir sie einem anderen Spieler
  # damit die Kapitäns Berechnung klappt.
  evtl_mit_max_trumpf = karten.include?(Karte.max_trumpf) ? [] : [Karte.max_trumpf]
  spiel_information.verteil_karten([karten, [], [], [], evtl_mit_max_trumpf])
  spieler.waehle_karte(stich_sicht)
end

def aktivierter_auftrag(auftrags_karte)
  auftrag = Auftrag.new(auftrags_karte)
  auftrag.aktivieren
  auftrag
end

def gruene(wert)
  Karte.new(farbe: Farbe::GRUEN, wert: wert)
end

def gelbe(wert)
  Karte.new(farbe: Farbe::GELB, wert: wert)
end

RSpec.describe Reinwerfer do
  subject(:reinwerfer) do
    reinwerfer = Reinwerfer.new
    reinwerfer.sehe_spiel_informations_sicht(spiel_informations_sicht)
    reinwerfer
  end

  # 2 Spieler vorher und 2 Spieler nachher erlaubt alle möglichen Situationen.
  let(:anzahl_spieler) { 5 }
  let(:spiel_information) { SpielInformation.new(anzahl_spieler: anzahl_spieler) }
  let(:spiel_informations_sicht) { spiel_information.fuer_spieler(0) }
  let(:spieler) { Spieler.new(entscheider: reinwerfer, spiel_informations_sicht: spiel_informations_sicht) }
  let(:standard_stich) do
    stich = Stich.new
    stich.legen(karte: gruene(5), spieler_index: 3)
    stich.legen(karte: gruene(6), spieler_index: 4)
    stich
  end
  let(:standard_stich_sicht) { standard_stich.fuer_spieler(spieler_index: 0, anzahl_spieler: anzahl_spieler) }
  let(:gestochener_stich) do
    stich = Stich.new
    stich.legen(karte: gruene(5), spieler_index: 3)
    stich.legen(karte: Karte.new(farbe: Farbe::RAKETE, wert: 1), spieler_index: 4)
    stich
  end
  let(:gestochene_stich_sicht) { gestochener_stich.fuer_spieler(spieler_index: 0, anzahl_spieler: anzahl_spieler) }
  let(:leerer_stich) { Stich.new }
  let(:leere_stich_sicht) { leerer_stich.fuer_spieler(spieler_index: 0, anzahl_spieler: anzahl_spieler) }

  it 'waehlt seine einzige waehlbare Karte' do
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [Karte.max_trumpf], standard_stich_sicht)
    expect(karte).to eq(Karte.max_trumpf)
  end

  it 'spielt irgendwas beim anspielen' do
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [Karte.max_trumpf], leere_stich_sicht)
    expect(karte).to eq(Karte.max_trumpf)
  end

  it 'wirft bei einem tötlichen Stich eine Auftragskarte der selben Farbe rein' do
    # Macht den Stich tötlich
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(5)))
    # Eigene reinwerfbare Karte, die Auftrag ist.
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(2)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(7)], standard_stich_sicht)
    expect(karte).to eq(gruene(2))
  end

  it 'wirft bei einem tötlichen Stich eine Auftragskarte einer anderen Farbe rein' do
    # Macht den Stich tötlich
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(5)))
    # Eigene reinwerfbare Karte, die Auftrag ist.
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gelbe(2)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gelbe(2), gelbe(7)], standard_stich_sicht)
    expect(karte).to eq(gelbe(2))
  end

  it 'wirft bei einem tötlichen Stich keine staerkere Auftragskarte rein' do
    # Macht den Stich tötlich
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(5)))
    # Eigene schlagende Karte, die Auftrag ist.
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(7)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(7)], standard_stich_sicht)
    expect(karte).to eq(gruene(2))
  end

  it 'wirft bei einem tötlichen Stich eine gefährliche Karte einer anderen Farbe rein' do
    # Macht den Stich tötlich
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(5)))
    # Eigene reinwerfbare Karte, die Auftrag ist.
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gelbe(5)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gelbe(2), gelbe(7)], standard_stich_sicht)
    expect(karte).to eq(gelbe(7))
  end

  it 'geht bei einem tötlichen Stich nicht drüber' do
    # Macht den Stich tötlich
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(5)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(7)], standard_stich_sicht)
    expect(karte).to eq(gruene(2))
  end

  it 'wirft bei einem tötlichen Stich nicht eine Auftragskarte eines anderen Spielers rein' do
    # Macht den Stich tötlich
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(5)))
    # Auftrag eines anderen Spielers
    spiel_information.auftrag_gewaehlt(spieler_index: 1, auftrag: aktivierter_auftrag(gruene(3)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(3)], standard_stich_sicht)
    expect(karte).to eq(gruene(2))
  end

  it 'nimmt an, dass ein gestochener Stich bleibt und wirft rein' do
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(2)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(3)], gestochene_stich_sicht)
    expect(karte).to eq(gruene(2))
  end

  it 'nimmt an, dass ein gestochener Stich bleibt und rettet Auftrag' do
    spiel_information.auftrag_gewaehlt(spieler_index: 3, auftrag: aktivierter_auftrag(gruene(2)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(3)], gestochene_stich_sicht)
    expect(karte).to eq(gruene(3))
  end

  xit 'nimmt an, dass eine sechs bleibt wenn er selber die 7 hat und wirft rein' do
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(2)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(3), gruene(7)], standard_stich_sicht)
    expect(karte).to eq(gruene(2))
  end

  xit 'nimmt an, dass eine sechs nicht bleibt und rettet Auftrag' do
    spiel_information.auftrag_gewaehlt(spieler_index: 4, auftrag: aktivierter_auftrag(gruene(2)))
    karte = lass_reinwerfer_karte_waehlen(spieler, spiel_information, [gruene(2), gruene(3)], standard_stich_sicht)
    expect(karte).to eq(gruene(3))
  end
end