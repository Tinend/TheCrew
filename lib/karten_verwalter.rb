# frozen_string_literal: true

require_relative 'auftrag'

# Verteilt die Karten an die Spieler
class KartenVerwalter
  def initialize(karten:, spiel_information:)
    @spiel_information = spiel_information
    @karten = karten
  end

  def verteilen(zufalls_generator: Random.new)
    @karten.shuffle!(random: zufalls_generator)
    anzahl_spieler = @spiel_information.anzahl_spieler
    blattgroesse = @karten.length / anzahl_spieler
    zusatzkarten = @karten.length - (blattgroesse * anzahl_spieler)
    verteilte_karten = anzahl_spieler.times.map do |i|
      anfang = (i * blattgroesse) + [i, zusatzkarten].min
      ende = ((i + 1) * blattgroesse) + [i + 1, zusatzkarten].min
      @karten[anfang...ende]
    end
    @spiel_information.verteil_karten(verteilte_karten)
  end
end
