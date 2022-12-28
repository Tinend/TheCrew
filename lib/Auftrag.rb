# frozen_string_literal: true

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
