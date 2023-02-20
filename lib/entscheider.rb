# frozen_string_literal: true

# Superklasse von allen Entscheidern, die jeweils einen Bot oder menschlichen darstellen und spielrelevante Infos
# bekommen und Entscheidungen treffen.
class Entscheider
  def initialize(zufalls_generator:, statistiker:)
    @zufalls_generator = zufalls_generator
    @statistiker = statistiker
  end

  def waehl_auftrag(auftraege)
    raise NotImplementedError
  end

  def waehle_karte(stich, waehlbare_karten)
    raise NotImplementedError
  end

  # Macht nix wenn nicht neu definiert.
  def sehe_spiel_informations_sicht(spiel_informations_sicht); end

  # Macht nix wenn nicht neu definiert.
  def stich_fertig(stich); end

  # Nil bedeutet keine Kommunikation.
  # Macht nix wenn nicht neu definiert.
  def waehle_kommunikation(kommunizierbares); end

  # Macht nix wenn nicht neu definiert.
  def vorbereitungs_phase; end
end
