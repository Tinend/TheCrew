# frozen_string_literal: true

require 'stich'
require 'kommunikation'

# Ein Spieler im TheCrew Spiel.
# Man beachte, dass diese Klasse keine Entscheidungen trifft. Sie verwaltet lediglich die Hand und die Aktionen des
# Spielers. Der `Entscheider` trifft die Entscheidungen.
class Spieler
  def initialize(entscheider:, spiel_informations_sicht:)
    @entscheider = entscheider
    @spiel_informations_sicht = spiel_informations_sicht
    @entscheider.sehe_spiel_informations_sicht(spiel_informations_sicht)
    @kann_kommunizieren = true
  end

  def auftraege
    @spiel_information.eigene_auftraege
  end

  def kommunizierbares
    karten.reject(&:trumpf?).group_by(&:farbe).flat_map do |_k, v|
      max = v.max_by(&:wert)
      min = v.min_by(&:wert)
      if max == min
        [Kommunikation.einzige(max)]
      else
        [Kommunikation.tiefste(min), Kommunikation.hoechste(max)]
      end
    end
  end

  def waehle_kommunikation
    return unless @kann_kommunizieren

    kommunikation = @entscheider.waehle_kommunikation(kommunizierbares)
    @kann_kommunizieren = false if kommunikation
    kommunikation
  end

  def waehl_auftrag(auftraege)
    auftrag = @entscheider.waehl_auftrag(auftraege)
    raise 'Entscheider hat einen nicht existierenden Auftrag gewaehlt.' unless auftraege.include?(auftrag)

    auftrag
  end

  def muss_bedienen?(stich)
    !stich.empty? && karten.any? { |k| k.farbe == stich.farbe }
  end

  def waehlbare_karten(stich)
    if muss_bedienen?(stich)
      karten.select { |k| k.farbe == stich.farbe }
    else
      karten
    end
  end

  def waehle_karte(stich)
    raise TypeError unless stich.is_a?(Stich)

    waehlbare = waehlbare_karten(stich)
    karte = @entscheider.waehle_karte(stich, waehlbare)
    raise 'Entscheider hat eine nicht spielbare Karte gewaehlt.' unless waehlbare.include?(karte)

    karte
  end

  def karten
    @spiel_informations_sicht.karten
  end
end
