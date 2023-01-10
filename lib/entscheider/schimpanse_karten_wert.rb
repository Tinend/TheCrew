# coding: utf-8
# frozen_string_literal: true

# Zum Sortieren der Legewerte von Karten für den Schimpansen
class SchimpanseKartenWert
  def initialize(wert:, array:)
    @wert = wert
    @array = array
  end

  attr_reader :array

  def <=>(other)
    @array <=> other.array
  end

  def verbessere(wert:, array:)
    return unless @wert < wert

    @wert = wert
    @array = array
  end
end
