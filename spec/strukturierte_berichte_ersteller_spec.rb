# coding: utf-8
# frozen_string_literal: true

require 'strukturierte_berichte_ersteller'
require 'entscheider_liste'

RSpec.describe StrukturierteBerichteErsteller do
  subject(:ersteller) do
    basis_verzeichnis = File.join(File.dirname(__FILE__), '..')
    described_class.new(basis_verzeichnis: basis_verzeichnis)
  end

  # rubocop:disable RSpec/MultipleExpectations
  xit 'hat den gleichen generierten und geladenen. Wenn dies fehlschlägt, einfach ' \
      'bin/erstelle_strukturierten_bericht ausführen und eventuell mit git diff die Diffs anschauen.' do
    erstellt = ersteller.erstelle_bericht
    geladen = ersteller.lade_bericht
    expect(erstellt[:punkte_bericht]).to eq(geladen[:punkte_bericht])
    EntscheiderListe.entscheider_klassen.each do |entscheider|
      erstellt_fuer_entscheider = erstellt[:spiel_berichte_pro_entscheider][entscheider.to_s]
      geladen_fuer_entscheider = geladen[:spiel_berichte_pro_entscheider][entscheider.to_s]
      expect(erstellt_fuer_entscheider).to eq(geladen_fuer_entscheider)
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
end
