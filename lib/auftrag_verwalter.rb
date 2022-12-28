class Auftrag_Verwalter
  def initialize(auftraege:, spieler:)
    @auftraege = auftraege
    @ausgelegte_auftraege = []
    @spieler = spieler
  end

  attr_reader :ausgelegte_auftraege
  
  def auftraege_ziehen(anzahl:, richter:)
    @auftraege.shuffle!
    @ausgelegte_auftraege = @auftraege[0...anzahl]
    @richter.auftraege_erhalten(@ausgelegte_auftraege)
  end

  def auftraege_verteilen()
    start = @spieler.find_index{|spieler| spieler.faegt_an?()}
    @ausgelegte_auftraege.length
  end

end
