# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'gemeinsam/saeuger_auftrag_nehmer'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'

# Aufträge: Wenn er ihn hat, bevorzugt groß, wenn er ihn nicht hat, bevorzugt tief
# Wirft höchste Karte wenn er Auftrag hat, tiefste Karte wenn anderer Auftrag hat und Auftrag, wenn möglich
class Hase < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender

  def finde_max_karte_aus_auswahl(auftrag:, moegliche_karten:)
    moegliche_karten.select { |karte| !karte.trumpf? && karte.schlaegt?(auftrag.karte) }.max_by(&:wert)
  end

  def anspielen(_stich, waehlbare_karten)
    return anderen_auftrag_anspielen(waehlbare_karten) if eigene_auftraege.empty?

    ziel_auftrag = eigene_auftraege.sample(random: @zufalls_generator)
    if waehlbare_karten.include?(ziel_auftrag.karte)
      ziel_auftrag.karte
    elsif waehlbare_karten.any? { |karte| karte.schlaegt?(ziel_auftrag.karte) && !karte.trumpf? }
      finde_max_karte_aus_auswahl(auftrag: ziel_auftrag, moegliche_karten: waehlbare_karten)
    else
      waehle_minimum(waehlbare_karten)
    end
  end

  def anderen_auftrag_anspielen(waehlbare_karten)
    if waehlbare_karten & alle_auftraege != []
      return waehle_minimum(waehlbare_karten & alle_auftraege.sample(random: @zufalls_generator))
    end

    waehle_minimum(waehlbare_karten)
  end

  def auftrag_abspielen(stich, waehlbare_karten)
    eigene_auftraege.each do |auftrag|
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
    return anspielen(stich, waehlbare_karten) if stich.empty?

    abspielen(stich, waehlbare_karten)
  end
end
