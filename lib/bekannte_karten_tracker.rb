# frozen_string_literal: true

# Klasse, die dafür zuständig ist, anhand gegangener Karten und Kommunikation
# einzuschränken, wer welche Karten haben könnte.
class BekannteKartenTracker
  def initialize(spiel_information:)
    @spiel_information = spiel_information
  end
end
