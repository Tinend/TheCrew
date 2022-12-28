# frozen_string_literal: true

class Spieler
  def initialize(entscheider)
    @entscheider = entscheider
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
    @karten = karten
    @entscheider.bekomm_karten(karten)
  end

  def muss_bedienen?(stich)
    @karten.any? { |k| k.farbe == stich.farbe }
  end

  def waehlbare_karten(stich)
    if muss_bedienen?(stich)
      @karten.select { |k| k.farbe == stich.farbe }
    else
      @karten
    end
  end

  def waehle_karte(stich)
    waehlbare = waehlbare_karten(stich)
    entscheider.waehle_karte(stich, waehlbare)
    raise 'Entscheider hat einen nicht existierenden Auftrag gewaehlt.' unless waehlbare.include?(karte)

    @karten.delete(karte)
    karte
  end

  def stich_fertig(stich)
    @entscheider.stich_fertig(stich)
  end
end
