# frozen_string_literal: true

require 'karte'
require 'stich'

# Ein Spieler im TheCrew Spiel.
# Man beachte, dass diese Klasse keine Entscheidungen trifft. Sie verwaltet lediglich die Hand und die Aktionen des
# Spielers. Der `Entscheider` trifft die Entscheidungen.
class Spieler
  def initialize(entscheider:, spiel_informations_sicht:)
    @entscheider = entscheider
    @spiel_informations_sicht = spiel_informations_sicht
    @karten = []
    @auftraege = []
  end

  attr_reader :auftraege

  def faengt_an?
    @karten.include?(Karte.max_trumpf)
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
    !@karten.emtpy?
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
end
