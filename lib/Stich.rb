# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require '/home/ulrich/ruby/Bananologen/Feld'

class Stich
  def initialize
    @sieger = nil
    @staerksteKarte = Karte.new(wert: 0, farbe: :antiRakete)
    @karten = []
    @farbe = nil
  end

  attr_reader :sieger, :karten, :farbe

  def legen(karte:, spieler:)
    if karte.schlaegt(staerksteKarte)
      @sieger = :spieler
      @staerksteKarte = karte
    end
    @karten.push(karte)
  end
end
