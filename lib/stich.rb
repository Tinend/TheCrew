# frozen_string_literal: true

require_relative 'karte'

# verwaltet einen Stich und Karten die drauf gelegt werden
class Stich
  def initialize
    @sieger = nil
    @staerkste_karte = Karte.nil_karte
    @karten = []
    @farbe = Karte.nil_karte.farbe
  end

  attr_reader :sieger, :karten, :farbe

  def legen(karte:, spieler:)
    if karte.schlaegt?(@staerkste_karte)
      @farbe = karte.farbe if @staerkste_karte == Karte.nil_karte
      @sieger = spieler
      @staerkste_karte = karte
    end
    @karten.push(karte)
  end

  def to_s
    @karten.join(' ')
  end
end
