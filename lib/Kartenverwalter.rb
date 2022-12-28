class Kartenverwalter
  def initialize(karten:, spieler:)
    @spieler = spieler
    @karten = karten
  end

  def verteilen()
    @karten.shuffle!
    zusatzkarten = @karten.length - @karten.length / @spieler.length * @spieler.length
    @spieler.each_with_index do |spieler, i|
      spieler.bekomm_karten
    end
  end
  
end
