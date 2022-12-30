# frozen_string_literal: true

require_relative '../entscheider'

# Entscheider, der immer zufällig entschiedet, was er spielt.
class ZufallsEntscheider < Entscheider
  def waehl_auftrag(auftraege)
    auftraege.sample
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample
  end

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end

  def karten
    @spiel_informations_sicht.karten
  end

  def kommuniziert?
    rand(karten.length).zero?
  end

  def waehle_kommunikation(kommunizierbares)
    kommunizierbares.sample if kommuniziert?
  end
end
