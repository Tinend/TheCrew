# frozen_string_literal: true

require_relative 'karte'

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
