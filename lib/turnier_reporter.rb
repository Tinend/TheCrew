# frozen_string_literal: true

require_relative 'leerer_reporter'
require_relative 'statistiken_putser'

# Dieser Reporter macht nichts ausser die Anzahl Punkte berichten.
class TurnierReporter < LeererReporter
  include StatistikenPutser

  def berichte_punkte(entscheider:, punkte:)
    puts "#{entscheider} hat #{punkte} Punkte geholt."
  end

  def berichte_gesamt_statistiken(gesamt_statistiken:, gewonnen_statistiken:, verloren_statistiken:)
    return unless @statistiken_ausgeben

    berichte_statistiken('Gesamt', gesamt_statistiken)
    berichte_statistiken('Gewonnen', gewonnen_statistiken)
    berichte_statistiken('Verloren', verloren_statistiken)
  end
end
