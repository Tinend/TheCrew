# frozen_string_literal: true

# Stellt einen Auftrag aus Sicht des Rhinoceros dar
class RhinocerosAuftrag
  def initialize(auftrag:, wahl_index:, spieler_index:, hat_selber:)
    @auftrag = auftrag
    @wahl_index = wahl_index
    @spieler_index = spieler_index
    @hat_selber = hat_selber
  end

  attr_reader :spieler_index, :wahl_index, :auftrag

  def hat_selber?
    @hat_selber
  end

  def farbe
    @auftrag.karte.farbe
  end

  def hat_selber_will_selber_farb_anspiel_wert(anzahl_karten)
    10 * (@auftrag.karte.wert - 8 + anzahl_karten * 2)
  end
  
  def hat_selber_farb_anspiel_wert(anzahl_karten)
    10 * (8 - @auftrag.karte.wert - anzahl_karten)
  end

  def will_selber_farb_anspiel_wert(anzahl_karten)
    10 * (8 - anzahl_karten * 2)
  end

  def sonst_farb_anspiel_wert(anzahl_karten)
    - 10 * anzahl_karten
  end
  
  def farb_anspiel_wert(anzahl_karten)
    return hat_selber_will_selber_farb_anspiel_wert(anzahl_karten) if @hat_selber and @spieler_index == 0
    return hat_selber_farb_anspiel_wert(anzahl_karten) if @hat_selber and @spieler_index != 0
    return will_selber_farb_anspiel_wert(anzahl_karten) if !@hat_selber and @spieler_index == 0
    return sonst_farb_anspiel_wert(anzahl_karten) if !@hat_selber and @spieler_index != 0
    raise
  end
end
