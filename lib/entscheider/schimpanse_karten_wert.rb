class SchimpanseKartenWert
  def initialize(wert:, array:)
    @wert = wert
    @array = array
  end

  attr_reader :array

  def <=>(x)
    @array <=> x.array
  end

  def verbessere(wert:, array:)
    if @wert < wert
      @wert = wert
      @array = array
    end
  end
end
