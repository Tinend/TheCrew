class Richter
  def initialize()
    @verloren = false
    @gewonnen = false
    @auftraege = []
  end

  attr_reader :gewonnen, :verloren
  
  def auftragErhalten(auftrag)
    @auftraege.push(auftrag)
  end

  def stechen(stich)
    stich.sieger.auftraege.each do |auftrag|
      stich.karten.each do |karte|
        auftrag.erfuellen(karte)
      end
    end
    @auftraege.delete_if {|auftrag| auftrag.erfuellt}
    if @auftraege.length == 0
      @gewonnen = true
    end
  end

  
end
