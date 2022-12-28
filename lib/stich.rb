# frozen_string_literal: true
# verwaltet einen Stich und Karten die drauf gelegt werden

require_relative 'karte'

class Stich
  def initialize
    @sieger = nil
    @staerksteKarte = Karte.nil_karte
    @karten = []
  end

  attr_reader :sieger, :karten

  def farbe
    @staerksteKarte.farbe
  end
  
  def legen(karte:, spieler:)
    if karte.schlaegt?(@staerksteKarte)
      @sieger = :spieler
      @staerksteKarte = karte
    end
    @karten.push(karte)
  end
end
