# coding: utf-8
# frozen_string_literal: true

# Zum Sortieren von Kommunikation für den Schimpansen
class SchimpansenLegeWert
  def initialize
    @werte = [0, 0, 0, 0, 0]
  end

  attr_reader :werte, :prioritaet

  def toeten
    @werte[0] = -1
  end

  def gefaehrden(wert)
    @werte[1] -= wert
  end

  def warnen(wert)
    @werte[2] -= wert
  end

  def benachteiligen(wert)
    @werte[3] -= wert
  end

  def nerven(wert)
    @werte[4] -= wert
  end

  def <=>(schimpansen_lege_wert)
    @werte <=> schimpansen_lege_wert.werte
  end
end
