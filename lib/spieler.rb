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

  attr_reader :entscheider

  def auftraege
    @spiel_informations_sicht.eigene_auftraege
  end

  def waehlbare_kommunikationen
    gegangene_stiche = @spiel_informations_sicht.stiche.length
    karten.reject(&:trumpf?).group_by(&:farbe).flat_map do |_k, v|
      max = v.max_by(&:wert)
      min = v.min_by(&:wert)
      if max == min
        [Kommunikation.einzige(karte: max, gegangene_stiche: gegangene_stiche)]
      else
        [Kommunikation.tiefste(karte: min, gegangene_stiche: gegangene_stiche),
         Kommunikation.hoechste(karte: max, gegangene_stiche: gegangene_stiche)]
      end
    end
  end

  def waehle_kommunikation
    return unless @kann_kommunizieren

    waehlbare = waehlbare_kommunikationen
    kommunikation = @entscheider.waehle_kommunikation(waehlbare)
    return unless kommunikation

    unless waehlbare.include?(kommunikation)
      raise 'Entscheider hat eine unmögliche Kommunikation gewaehlt.' \
            "Waehlbare: #{waehlbare.join(' ')}; gewaehlt: #{kommunikation}"
    end
    @kann_kommunizieren = false
    kommunikation
  end

  def waehl_auftrag(auftraege)
    auftrag = @entscheider.waehl_auftrag(auftraege)
    raise "Entscheider hat nicht existierenden Auftrag #{auftrag} gewaehlt." unless auftraege.include?(auftrag)

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
    raise 'Spieler kann ohne Karten nicht spielen' if karten.empty?
    raise TypeError unless stich.is_a?(Stich::StichSicht)

    waehlbare = waehlbare_karten(stich)
    @spiel_informations_sicht.erhalte_aktiven_stich(stich)
    karte = @entscheider.waehle_karte(stich, waehlbare)
    unless waehlbare.include?(karte)
      raise 'Entscheider hat eine nicht spielbare Karte gewaehlt.' \
            "Waehlbare: #{waehlbare.join(' ')}; gewaehlt: #{karte}"
    end
    @spiel_informations_sicht.entferne_aktiven_stich

    karte
  end

  def karten
    @spiel_informations_sicht.karten
  end

  def vorbereitungs_phase
    @entscheider.vorbereitungs_phase
  end
end
