# coding: utf-8
# frozen_string_literal: true

# Fasst die Karte, den Wert und das Symbol einer Karte
# für den Elefanten zusammen
class ElefantRueckgabe
  def initialize(karte)
    @karte = karte
    @wert = [0, 0, 0, 0, 0]
    @symbol = :nichts
  end

  attr_accessor :symbol, :wert
  attr_reader :karte

  def <=>(other)
    -(other <=> wert)
  end
end
