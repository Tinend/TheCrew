# frozen_string_literal: true

# Superklasse von allen Entscheidern, die jeweils einen Bot oder menschlichen darstellen und spielrelevante Infos
# bekommen und Entscheidungen treffen.
class Entscheider
  def initialize(zufalls_generator:, zaehler_manager:)
    @zufalls_generator = zufalls_generator
    @zaehler_manager = zaehler_manager
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

  # Der Reporter, der diesem Spieler weiter leitet, was im Spiel passiert.
  # Kann zum Beispiel benutzt werden, um ihn nach einem Verlust zu benachrichtigen.
  # Macht nix wenn nicht neu definiert.
  def reporter; end
end
