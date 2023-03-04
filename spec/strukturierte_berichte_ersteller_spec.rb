# coding: utf-8
# frozen_string_literal: true

require 'strukturierte_berichte_ersteller'
require 'entscheider_liste'

RSpec.describe StrukturierteBerichteErsteller do
  EntscheiderListe.entscheider_klassen.each do |entscheider_klasse|
    context entscheider_klasse.to_s do
      subject(:ersteller) do
        basis_verzeichnis = File.join(File.dirname(__FILE__), '..')
        described_class.new(basis_verzeichnis: basis_verzeichnis, entscheider_klasse: entscheider_klasse)
      end

      let(:erstellt) do
        (@erstellt ||= {})[entscheider_klasse.to_s] ||= ersteller.erstelle_bericht
      end
      let(:geladen) do
        (@geladen ||= {})[entscheider_klasse.to_s] ||= ersteller.lade_bericht
      end

      it 'macht im Turnier gleich viele Punkte wie die geladene Punkte Entwicklung. Wenn dies fehlschlägt, einfach ' \
         "bin/erstelle_strukturierten_bericht -x=#{entscheider_klasse} ausführen " \
         'und eventuell mit git diff die Diffs anschauen.' do
        skip 'QLearningEntscheider ist noch nicht bereit' if entscheider_klasse == QLearningEntscheider
        expect(erstellt[:punkte]).to eq(geladen[:punkte])
      end

      it 'macht im Turnier den gleichen Spielbericht wie den geladenen. Wenn dies fehlschlägt, einfach ' \
         "bin/erstelle_strukturierten_bericht -x=#{entscheider_klasse} ausführen " \
         'und eventuell mit git diff die Diffs anschauen.' do
        skip 'QLearningEntscheider ist noch nicht bereit' if entscheider_klasse == QLearningEntscheider
        expect(erstellt[:spiel_berichte]).to eq(geladen[:spiel_berichte])
      end
    end
  end
end
