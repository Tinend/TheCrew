# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'

# Aufträge: Wenn er ihn hat, bevorzugt groß, wenn er ihn nicht hat, bevorzugt tief
# Wirft höchste Karte wenn er Auftrag hat, tiefste Karte wenn anderer Auftrag hat und Auftrag, wenn möglich
class Hase < Entscheider
  def waehl_auftrag(auftraege)
    auftraege.max_by do |auftrag|
      wert = 0
      if @karten.include?(auftrag.karte)
        wert = auftrag.karte.wert
      else
        max_karte = finde_max_karte(auftrag: auftrag, karten: @karten)
        wert = if max_karte.nil?
                 0
               else
                 max_karte.wert - (auftrag.karte.wert * 0.1)
               end
      end
      wert
    end
  end

  def finde_max_karte(auftrag:, karten: @karten)
    karten.select { |karte| !karte.trumpf? && karte.schlaegt?(auftrag.karte) }.max_by(&:wert)
  end

  def anspielen(_stich, waehlbare_karten)
    return anderen_auftrag_anspielen(waehlbare_karten) if @spiel_informations_sicht.auftraege[0].length.zero?

    ziel_auftrag = @spiel_informations_sicht.auftraege[0].sample
    if waehlbare_karten.include?(ziel_auftrag.karte)
      ziel_auftrag.karte
    elsif waehlbare_karten.any? { |karte| karte.schlaegt?(ziel_auftrag.karte) && !karte.trumpf? }
      finde_max_karte(auftrag: ziel_auftrag, karten: waehlbare_karten)
    elsif waehlbare_karten & @spiel_informations_sicht.auftraege.flatten != []
      waehle_minimum(waehlbare_karten & @spiel_informations_sicht.auftraege.flatten)
    else
      waehle_minimum(waehlbare_karten)
    end
  end

  def anderen_auftrag_anspielen(waehlbare_karten)
    if waehlbare_karten & @spiel_informations_sicht.auftraege.flatten != []
      return waehle_minimum(waehlbare_karten & @spiel_informations_sicht.auftraege.flatten.sample)
    end

    waehle_minimum(waehlbare_karten)
  end

  def auftrag_abspielen(stich, waehlbare_karten)
    @spiel_informations_sicht.auftraege[0].each do |auftrag|
      if auftrag_holen?(auftrag: auftrag, stich: stich, waehlbare_karten: waehlbare_karten)
        return waehlbare_karten.select { |karte| karte.farbe == stich.farbe }.min_by(&:wert)
      elsif auftrag_selber_abspielen?(auftrag: auftrag, stich: stich, waehlbare_karten: waehlbare_karten)
        return auftrag.karte
      end
    end
    nil
  end

  def auftrag_selber_abspielen?(auftrag:, stich:, waehlbare_karten:)
    auftrag.karte.farbe == stich.farbe &&
      waehlbare_karten.include?(auftrag.karte) &&
      auftrag.karte.schlaegt?(stich.staerkste_karte)
  end

  def auftrag_holen?(auftrag:, stich:, waehlbare_karten:)
    auftrag.karte.farbe == stich.farbe && !waehlbare_karten.include?(auftrag.karte) && waehlbare_karten.any? do |karte|
      karte.farbe == stich.farbe and karte.schlaegt?(stich.staerkste_karte)
    end
  end

  def abspielen(stich, waehlbare_karten)
    rueck = auftrag_abspielen(stich, waehlbare_karten)
    return rueck unless rueck.nil?

    @spiel_informations_sicht.auftraege[1..].reduce(:+).each do |auftrag|
      return auftrag.karte if waehlbare_karten.include?(auftrag.karte)
    end
    waehle_minimum(waehlbare_karten)
  end

  def waehle_minimum(karten)
    karten.min_by do |karte|
      wert = karte.wert
      wert += 10 if karte.trumpf?
      wert
    end
  end

  def waehle_karte(stich, waehlbare_karten)
    return anspielen(stich, waehlbare_karten) if stich.farbe == Farbe::ANTI_RAKETE

    abspielen(stich, waehlbare_karten)
  end

  def bekomm_karten(karten)
    @karten = karten
  end

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end
end
