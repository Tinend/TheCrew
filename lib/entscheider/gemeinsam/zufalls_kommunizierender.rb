# coding: utf-8
# frozen_string_literal: true

# Modul für Entscheider, die zufällig kommunizieren.
module ZufallsKommunizierender
  def kommuniziert?
    @zufalls_generator.rand(karten.length).zero?
  end

  def waehle_kommunikation(kommunizierbares)
    kommunizierbares.sample(random: @zufalls_generator) if kommuniziert?
  end
end
