class Hand

  def initialize(karten: = [])
    @karten = karten
  end

  def ziehen(karte)
    @karten.push(karte)
  end

  def legen(karte)
    @karten.delete(karte)
  end
  
  def erlaubt?(karte, stich)
    return false unless @karten.any? {|k| k == karte}
    return false if karte.farbe != stich.farbe and @karten.any?{|k| k.farbe == stich.farbe}
  end
 
end
