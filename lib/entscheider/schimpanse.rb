# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'saeuger_auftrag_nehmer'
require_relative 'spiel_informations_sicht_benutzender'
require_relative 'rhinoceros_abspielen'

# Hangelt sich zwischen den Aufträgen durch
# Basiert auf Rhinoceros, aber ist weiterentwickelt
# und kann kommunizieren
class Schimpanse < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender
  include RhinocerosAbspielen

  def anspielen(waehlbare_karten)
    waehlbare_karten.max_by { |karte| anspiel_wert_karte(karte) }
  end

  def eigenen_unerfuellten_auftrag_anspielen(karte)
    if karte.wert >= 6
      karte.wert * 1000
    else
      karte.wert
    end
  end

  def anderen_unerfuellten_auftrag_anspielen(karte)
    if karte.wert <= 7
      100 - (karte.wert * 10)
    else
      6900 - (1000 * karte.wert)
    end
  end

  def anspielen_auftrag_holen(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? do |auftrag|
         (auftrag.farbe == karte.farbe) && (auftrag.karte.wert <= karte.wert)
       end
      (100 * karte.wert) - 490
    else
      karte.wert - 100
    end
  end

  def lange_farbe_schranke(farbe)
    (@spiel_informations_sicht.karten_mit_farbe(farbe).length * @spiel_informations_sicht.anzahl_spieler) - 1
  end

  def lange_farbe?(farbe)
    karten = Karte.alle_mit_farbe(farbe)
    karten.reject { |karte| @spiel_informations_sicht.ist_gegangen?(karte) }
    karten.length < lange_farbe_schranke(farbe)
  end

  # rubocop:disable Lint/DuplicateBranch
  def auftrag_farbe_mit_holbarem_auftrag_anspielen(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[1..].flatten.length.zero?
      anspielen_auftrag_holen(karte)
    elsif lange_farbe?(karte.farbe)
      10 - karte.wert
    else
      anspielen_auftrag_holen(karte)
    end
  end

  def auftrag_farbe_anspielen(karte)
    if !@spiel_informations_sicht.unerfuellte_auftraege_nicht_auf_eigener_hand_mit_farbe(karte.farbe)[0].empty?
      auftrag_farbe_mit_holbarem_auftrag_anspielen(karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length.zero?
      30 - karte.wert
    elsif !@spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[1..].flatten.empty?
      30 - karte.wert
    elsif lange_farbe?(karte.farbe)
      karte.wert + 10
    else
      karte.wert - 5
    end
  end
  # rubocop:enable Lint/DuplicateBranch:

  def blank_machen_anspielen(karte)
    if karte.trumpf?
      - 100 * karte.wert
    elsif lange_farbe?(karte.farbe)
      karte.wert
    else
      -karte.wert
    end
  end

  def stich_abgeben_anspielen(karte)
    if karte.trumpf?
      - 100 * karte.wert
    else
      5 - karte.wert
    end
  end

  def abgedeckt(auftrag)
    @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe).any? do |karte|
      karte.wert >= auftrag.karte.wert && karte.wert >= 7
    end
  end

  def unerfuellten_auftrag_anspielen(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.karte == karte }
      eigenen_unerfuellten_auftrag_anspielen(karte)
    else
      anderen_unerfuellten_auftrag_anspielen(karte)
    end
  end

  # wie gut eine Karte zum Anspielen geeignet ist
  def anspiel_wert_karte(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege.flatten.any? { |auftrag| auftrag.karte == karte }
      unerfuellten_auftrag_anspielen(karte)
    elsif !@spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.empty?
      auftrag_farbe_anspielen(karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| !abgedeckt(auftrag) }
      blank_machen_anspielen(karte)
    else
      stich_abgeben_anspielen(karte)
    end
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

  # Findet raus, wer einen Auftrag im Stich hat. Wenn niemand einen hat, gibt es 0 zurück
  def finde_auftrag(stich)
    stich.karten.each do |karte|
      @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
        return spieler_index if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
      end
    end
    nil
  end

  def abspielen(stich, waehlbare_karten)
    waehlbare_karten.max_by { |karte| abspiel_wert_karte(karte, stich) }
  end

  def waehle_karte(stich, waehlbare_karten)
    if stich.karten.length.zero?
      anspielen(waehlbare_karten)
    else
      abspielen(stich, waehlbare_karten)
    end
  end
end
