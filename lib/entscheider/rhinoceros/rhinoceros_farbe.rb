# frozen_string_literal: true

# Stellt eine Farbe aus Sicht vom Rhinoceros dar
# Dient zur analyse, ob eine Farbe angespielt werden sollte oder nicht
class RhinocerosFarbe
  def initialize(farbe:, anzahl:, eigene_anzahl:, spiel_informations_sicht:)
    @farbe = farbe
    @anzahl_urspruenglich = anzahl
    @anzahl = anzahl
    @urspruengliche_eigene_anzahl = eigene_anzahl
    @auftraege = []
    @spiel_informations_sicht = spiel_informations_sicht
  end

  attr_reader :schwierigkeit, :farbe, :anzahl

  def auftrag_erhalten(auftrag)
    @auftraege.push(auftrag)
  end

  def analysieren
    @schwierigkeit = farb_auftrag_pro_spieler.reduce(0) do |anfang, anzahl|
      wert = anfang + anzahl
      wert += 10 if anzahl.positive?
      wert
    end
    @schwierigkeit += 100 if @farbe.trumpf?
    @selbst_auftrag = farb_auftrag_pro_spieler[0] != 0
  end

  def eigene_karten_erhalten(karten)
    @karten = karten
  end

  def farb_auftrag_pro_spieler
    @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(@farbe).collect(&:length)
  end

  def auftrag_verteilungs_wert
    wert = - farb_auftrag_pro_spieler.sum
    wert += 20 if farb_auftrag_pro_spieler[0].positive?
    wert
  end

  def eigene_anzahl
    @spiel_informations_sicht.karten_mit_farbe(@farbe).length
  end

  def anspielen_wert
    return -1000 if eigene_anzahl.zero?
    return 0 if farb_auftrag_pro_spieler.sum.zero?

    wert = @auftraege.reduce(0) { |w, auftrag| w + auftrag.farb_anspiel_wert(eigene_anzahl) }
    wert += auftrag_verteilungs_wert
    wert
  end

  def hat_fremden_auftrag?(stich)
    stich.gespielte_karten.any? do |gespielte_karte|
      @spiel_informations_sicht.auftraege[1..].flatten.any? { |auftrag| auftrag.karte == gespielte_karte.karte }
    end
  end

  def hat_eigenen_auftrag?(stich)
    stich.gespielte_karten.any? do |gespielte_karte|
      @spiel_informations_sicht.auftraege[0].any? { |auftrag| auftrag.karte == gespielte_karte.karte }
    end
  end

  def abspiel_wert_trumpf(stich)
    return 9000 if hat_eigenen_auftrag?(stich)
    return -11_000 if hat_fremden_auftrag?(stich)

    -1000
  end

  def abspiel_abwerfen(_stich)
    return 0 if farb_auftrag_pro_spieler.sum.zero?
    return -10 if farb_auftrag_pro_spieler[0].positive?

    10
  end

  def abspiel_wert(stich)
    return abspiel_wert_trumpf(stich) if @farbe.trumpf?
    return abspiel_abwerfen(stich) if @farbe != stich.staerkste_karte.farbe

    0
  end
end
