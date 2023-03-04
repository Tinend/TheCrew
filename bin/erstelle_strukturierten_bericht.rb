#!/usr/bin/ruby
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'strukturierte_berichte_ersteller'
require 'entscheider_liste'

entscheider_setzer = nil
ARGV.each do |a|
  entscheider_setzer = a[3..] if a[0..1] == '-x'
end
entscheider = EntscheiderListe.entscheider_klassen.find { |e| e.to_s == entscheider_setzer }
raise 'Diesen Entscheider gibt es nicht!' unless entscheider

ersteller = StrukturierteBerichteErsteller.new(basis_verzeichnis: File.join(File.dirname(__FILE__), '..'),
                                               entscheider_klasse: entscheider)
ersteller.speichere_bericht(ersteller.erstelle_bericht)
