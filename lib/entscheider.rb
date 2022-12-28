# frozen_string_literal: true

# Superklasse von allen Entscheidern, die jeweils einen Bot oder menschlichen darstellen und spielrelevante Infos bekommen und Entscheidungen treffen.
class Entscheider
  def waehl_auftrag(auftraege)
    raise NotImplementedError
  end

  def waehle_karte(stich, waehlbare_karten)
    raise NotImplementedError
  end

  # Macht nix wenn nicht neu definiert.
  def bekomm_karten(karten); end

  # Macht nix wenn nicht neu definiert.
  def stich_fertig(stich); end
end
