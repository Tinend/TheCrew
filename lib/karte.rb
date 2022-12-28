# frozen_string_literal: true

class Karte
  def initialize(wert:, farbe:)
    @wert = wert
    @farbe = farbe
  end

  attr_reader :wert, :farbe

  def schlaegt?(karte)
    if (karte.farbe == :rakete) && ((@farbe != :rakete) || (@wert <= karte.wert))
      false
    elsif farbe == :rakete
      true
    elsif farbe == :antiRakete
      false
    elsif karte.farbe == :antiRakete
      true
    else
      farbe == karte.farbe
    end
  end
end
