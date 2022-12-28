# frozen_string_literal: true

require_relative 'auftrag'

# Verteilt die Karten an die Spieler
class KartenVerwalter
  def initialize(karten:, spieler:)
    @spieler = spieler
    @karten = karten
  end

  def verteilen
    @karten.shuffle!
    blattgroesse = @karten.length / @spieler.length
    zusatzkarten = @karten.length - (blattgroesse * @spieler.length)
    @spieler.each_with_index do |spieler, i|
      anfang = (i * blattgroesse) + [i, zusatzkarten].min
      ende = ((i + 1) * blattgroesse) + [i + 1, zusatzkarten].min
      spieler.bekomm_karten(@karten[anfang...ende])
    end
  end
end
