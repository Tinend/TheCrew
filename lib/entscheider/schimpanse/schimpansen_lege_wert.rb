# coding: utf-8
# frozen_string_literal: true

# Zum Sortieren von Kommunikation für den Schimpansen
class SchimpansenLegeWert
  def initialize(prioritaet:)
    @werte = [0, 0, 0, 0, 0]
    @prioritaet = prioritaet
  end

  attr_reader :werte, :prioritaet

  def toedlich
    @werte[0] = -1
  end

  def gefahr(wert)
    @werte[1] -= wert
  end

  def warnung(wert)
    @werte[2] -= wert
  end

  def nachteil(wert)
    @werte[3] -= wert
  end
  
  def verbessere(werte:, prioritaet:)
    return unless @prioritaet < prioritaet

    @prioritaet = prioritaet
    @werte = werte
  end

  def <=>(schimpansen_lege_wert)
    @werte <=> schimpansen_lege_wert.werte
  end
end
