# frozen_string_literal: true

require 'karte'
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
    @karten = []
    @auftraege = []
    @kann_kommunizieren = true
  end

  attr_reader :auftraege, :karten

  def faengt_an?
    @karten.include?(Karte.max_trumpf)
  end

  def kommunizierbares
    @karten.reject(&:trumpf?).group_by(&:farbe).flat_map do |_k, v|
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

    @auftraege.push(auftrag)
    auftrag
  end

  def bekomm_karten(karten)
    raise TypeError unless karten.is_a?(Array) && karten.all?(Karte)

    @karten = karten
    @entscheider.bekomm_karten(karten)
  end

  def muss_bedienen?(stich)
    @karten.any? { |k| k.farbe == stich.farbe }
  end

  def hat_karten?
    !@karten.empty?
  end

  def waehlbare_karten(stich)
    if muss_bedienen?(stich)
      @karten.select { |k| k.farbe == stich.farbe }
    else
      @karten
    end
  end

  def waehle_karte(stich)
    raise TypeError unless stich.is_a?(Stich)

    waehlbare = waehlbare_karten(stich)
    karte = @entscheider.waehle_karte(stich, waehlbare)
    raise 'Entscheider hat eine nicht spielbare Karte gewaehlt.' unless waehlbare.include?(karte)

    @karten.delete(karte)
    karte
  end

  def to_s
    (karten.sort.reduce('') { |start, karte| "#{start} #{karte}" })[1..]
  end

  def vorbereitungs_phase
    @entscheider.vorbereitungs_phase
  end
end
