# frozen_string_literal: true

# Helfer für Entscheider, um Statistiken zu erstellen, zB wie oft
# eine bestimmte Situation eintrifft.
class Statistiker
  def initialize
    @zaehler = {}
    @zaehler.default = 0
  end

  def erhoehe_zaehler(zaehler_name)
    @zaehler[zaehler_name] += 1
  end

  def statistiken
    return '  Keine Statistiken erfasst' if @zaehler.empty?

    @zaehler.map do |k, v|
      "  #{k}: #{v}"
    end.join("\n")
  end
end
