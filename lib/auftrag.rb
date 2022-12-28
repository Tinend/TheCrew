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

  def erfuellen(karte)
    return unless karte == @karte
    @erfuellt = true
  end

  def aktivieren
    @erfuellt = false
  end

  def eql?(other)
    self.class == other.class && @erfuellt == other.erfuellt && @karte == other.karte
  end

  alias == eql?

  def hash
    [self.class, @erfuellt, @karte].hash
  end
end
