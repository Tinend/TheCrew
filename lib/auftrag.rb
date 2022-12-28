# coding: utf-8
# frozen_string_literal: true
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
end
