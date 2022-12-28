class Karte
  def initialize(wert:, farbe:)
    @wert = wert
    @farbe = farbe
  end

  attr_reader :wert, :farbe

  def schlaegt?(karte)
    if karte.farbe == :rakete and (@farbe != :rakete or @wert <= karte.wert)
      return false
    elsif farbe == :rakete
      return true
    elsif farbe == :antiRakete
      return false
    elsif karte.farbe == :antiRakete
      return true
    elsif farbe != karte.farbe
      return false
    else
      return true
    end
    
  end
  
end
