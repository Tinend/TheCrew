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

  def length
    @karten.length
  end

  def empty?
    @karten.empty?
  end

  def legen(karte:, spieler:)
    if karte.schlaegt?(@staerkste_karte)
      @sieger = spieler
      @staerkste_karte = karte
    end
    @karten.push(karte)
  end

  def to_s
    @karten.join(' ')
  end
end
