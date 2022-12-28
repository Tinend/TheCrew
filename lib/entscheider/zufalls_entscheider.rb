# frozen_string_literal: true

# Entscheider, der immer zufällig entschiedet, was er spielt.
class ZufallsEntscheider < Entscheider
  def waehl_auftrag(auftraege)
    auftraege.sample
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample
  end
end
