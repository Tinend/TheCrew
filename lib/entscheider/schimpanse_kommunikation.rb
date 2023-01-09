class SchimpanseKommunikation
  def initialize(kommunikation:, prioritaet:)
    @kommunikation = kommunikation
    @prioritaet = prioritaet
  end

  attr_reader :kommunikation, :prioritaet
  
  def verbessere(schimpansen_kommunikation)
    if @prioritaet < schimpansen_kommunikation.prioritaet
      @prioritaet = schimpansen_kommunikation.prioritaet
      @kommunikation = schimpansen_kommunikation.kommunikation
    end
  end
end
