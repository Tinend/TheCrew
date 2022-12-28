# frozen_string_literal: true

require_relative 'karte'

# verwaltet einen Stich und Karten die drauf gelegt werden
class Stich
  def initialize
    @sieger = nil
    @staerkste_karte = Karte.nil_karte
    @karten = []
  end

  attr_reader :sieger, :karten

  def farbe
    @staerkste_karte.farbe
  end
  
  def legen(karte:, spieler:)
    if karte.schlaegt?(@staerkste_karte)
      @sieger = spieler
      @staerkste_karte = karte
    end
    @karten.push(karte)
  end
end
