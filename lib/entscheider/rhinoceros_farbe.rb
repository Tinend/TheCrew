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
    wert = farb_auftrag_pro_spieler.reduce(1) { |produkt, anzahl| produkt * (anzahl + 4) }
    wert / (farb_auftrag_pro_spieler[0] + 1)
  end

  def eigene_anzahl
    @spiel_informations_sicht.karten_mit_farbe(@farbe).length
  end
  
  def anspielen_wert
    return -1000 if eigene_anzahl.zero?
    return 0 if farb_auftrag_pro_spieler.sum.zero?

    wert = @auftraege.reduce(0) { |w, auftrag| w + auftrag.farb_anspiel_wert(eigene_anzahl) }
    wert -= auftrag_verteilungs_wert
    wert
  end
end
