class Auftrag
  def initialize(karte)
    @erfuellt = true
    @karte = karte
  end

  attr_reader :karte, :erfuellt

  def erfuellen(karte)
    if karte == @karte
      @erfuellt = true
    end
  end

  def aktivieren()
    @erfuellt = false
  end

end
