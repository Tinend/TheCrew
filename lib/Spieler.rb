class Spieler
  def initialize(entscheider)
    @entscheider = entscheider
    @karten = []
    @auftraege = []
  end

  attr_reader :auftraege

  def waehl_auftrag(auftraege)
    auftrag = @entscheider.waehl_auftrag(auftraege)
    raise "Entscheider hat einen nicht existierenden Auftrag gewaehlt." unless auftraege.include?(auftrag)

    @auftraege.push(auftrag)
    auftrag
  end

  def bekomm_karten(karten)
    @karten = karten
    @entscheider.bekomm_karten(karten)
  end

  def waehle_karte(stich)
    entscheider.waehle_karte(stich)
    raise "Entscheider hat einen nicht existierenden Auftrag gewaehlt." unless @karten.include?(karte)

    @karten.delete(karte)
    karte
  end

  def stich_fertig(stich)
    @entscheider.stich_fertig(stich)
  end
end
