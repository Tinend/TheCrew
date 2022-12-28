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

  def bekomm_karten(karten)
    @anzahl_anfangs_karten = karten.length
  end

  def kommuniziert?
    karten = @anzahl_anfangs_karten - @spiel_informations_sicht.stiche.length
    rand(karten).zero?
  end

  def waehle_kommunikation(kommunizierbares)
    kommunizierbares.sample if kommuniziert?
  end
end
