# frozen_string_literal: true

class Kartenverwalter
  def initialize(karten:, spieler:)
    @spieler = spieler
    @karten = karten
  end

  def verteilen
    @karten.shuffle!
    blattgroesse = @karten.length / @spieler.length
    zusatzkarten = @karten.length - blattgroesse * @spieler.length
    @spieler.each_with_index do |spieler, i|
      spieler.bekomm_karten(@karten[i * blattgroesse + [i,
                                                        zusatzkarten].min..(i + 1) * blattgroesse + [i + 1,
                                                                                                     zusatzkarten].min])
    end
  end
end
