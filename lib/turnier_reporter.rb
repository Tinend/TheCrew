# frozen_string_literal: true

require_relative 'leerer_reporter'

# Dieser Reporter macht nichts ausser die Anzahl Punkte berichten.
class TurnierReporter < LeererReporter
  def berichte_punkte(entscheider:, punkte:)
    puts "#{entscheider} hat #{punkte} Punkte geholt."
  end

  def berichte_statistiken
    puts @statistiker.statistiken
  end
end
