require 'strukturierte_berichte_ersteller'
require 'entscheider_liste'

RSpec.describe StrukturierteBerichteErsteller do
  subject(:ersteller) do
    basis_verzeichnis = File.join(File.dirname(__FILE__), '..')
    StrukturierteBerichteErsteller.new(basis_verzeichnis: basis_verzeichnis)
  end

  it 'hat den gleichen generierten und geladenen. Wenn dies fehlschlägt, einfach ' \
     'bin/erstelle_strukturierten_bericht ausführen und eventuell mit git diff die Diffs anschauen.' do
    erstellt = ersteller.erstelle_bericht
    geladen = ersteller.lade_bericht
    expect(erstellt[:punkte_bericht]).to eq(geladen[:punkte_bericht])
    EntscheiderListe.entscheider_klassen.each do |entscheider|
      expect(erstellt[:spiel_berichte_pro_entscheider][entscheider.to_s]).to eq(geladen[:spiel_berichte_pro_entscheider][entscheider.to_s])
    end
  end
end
