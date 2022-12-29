# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'

# Aufträge: Wenn er ihn hat, bevorzugt groß, wenn er ihn nicht hat, bevorzugt tief
# Wirft höchste Karte wenn er Auftrag hat, tiefste Karte wenn anderer Auftrag hat und Auftrag, wenn möglich
class Saeuger < Entscheider
  def waehl_auftrag(auftraege)
    auftraege.max_by do |auftrag|
      wert = 0
      if @karten.include?(auftrag.karte)
        wert = auftrag.karte.wert
      elsif @karten.any? { |karte| (karte.farbe == auftrag.karte.farbe) && karte.schlaegt?(auftrag.karte) }
        wert = @karten.select { |karte| karte.farbe == auftrag.karte.farbe }.max_by(&:wert).wert
        wert -= auftrag.karte.wert * 0.1
      end
      wert
    end
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample
  end

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end

  def bekomm_karten(karten)
    @anzahl_anfangs_karten = karten.length
  end

  def kommuniziert?
    karten = @anzahl_anfangs_karten - @spiel_informations_sicht.stiche.length
    rand(karten).zero?
  end

  def waehle_kommunikation(kommunizierbares)
    kommunizierbares.sample if kommuniziert?
  end
end
