# coding: utf-8
# frozen_string_literal: true

require_relative 'karte'

# Auftrag zu einer Karte, der erfüllt werden muss
class Auftrag
  def initialize(karte)
    @erfuellt = true
    @karte = karte
  end

  attr_reader :karte, :erfuellt

  def self.alle
    Karte.alle_normalen.map { |karte| new(karte) }.freeze
  end

  def erfuellen(karte)
    return unless karte == @karte

    @erfuellt = true
  end

  def aktivieren
    @erfuellt = false
  end

  def <=>(other)
    [farbe.sortier_wert, @karte.wert] <=> [other.farbe.sortier_wert, other.karte.wert]
  end

  def eql?(other)
    self.class == other.class && @erfuellt == other.erfuellt && @karte == other.karte
  end

  alias == eql?

  def hash
    [self.class, @erfuellt, @karte].hash
  end

  def to_s
    karte.to_s
  end

  def farbe
    karte.farbe
  end
end
