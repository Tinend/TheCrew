#!/usr/bin/ruby
# frozen_string_literal: true

libx = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'strukturierte_berichte_ersteller'

ersteller = StrukturierteBerichteErsteller.new(basis_verzeichnis: File.join(File.dirname(__FILE__), '..'))
ersteller.speichere_bericht(ersteller.erstelle_bericht)
