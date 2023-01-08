# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'saeuger_auftrag_nehmer'
require_relative 'spiel_informations_sicht_benutzender'


# Rennt geradewegs auf die Aufträge zu
# Geht 100 Fälle durch und wählt geeigneten aus
class Rhinoceros < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender

  def anspielen(waehlbare_karten)
    waehlbare_karten.max_by { |karte| anspiel_wert_karte(karte) }
  end

  def eigenen_unerfuellten_auftrag_anspielen(karte)
    if karte.wert >= 6
      return karte.wert * 1000
    else
      return karte.wert
    end
  end

  def anderen_unerfuellten_auftrag_anspielen(karte)
    if karte.wert <= 7
      return 100 - karte.wert * 10
    else
      return 6900 - 1000 * karte.wert
    end
  end
  
  def anspielen_auftrag_holen(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? do |auftrag|
        (auftrag.farbe == karte.farbe) && (auftrag.karte.wert <= karte.wert)
      end
      return 100 * karte.wert - 490
    else
      return karte.wert - 100
    end
  end
  
  def lange_farbe?(farbe)
    karten = Karte.alle_mit_farbe(farbe)
    karten.select {|karte| ! @spiel_informations_sicht.ist_gegangen?(karte)}
    karten.length < @spiel_informations_sicht.karten_mit_farbe(farbe).length * @spiel_informations_sicht.anzahl_spieler - 1
  end

  def auftrag_farbe_mit_holbarem_auftrag_anspielen(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[1..].flatten.length == 0
      return anspielen_auftrag_holen(karte)
    elsif lange_farbe?(karte.farbe)
      return 10 - karte.wert
    else
      return anspielen_auftrag_holen(karte)
    end    
  end
  
  def auftrag_farbe_anspielen(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege_nicht_auf_eigener_hand_mit_farbe(karte.farbe)[0].length != 0
      return auftrag_farbe_mit_holbarem_auftrag_anspielen(karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length.zero?
      return 30 - karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[1..].flatten.length != 0
      return 30 - karte.wert
    elsif lange_farbe?(karte.farbe)
      return karte.wert + 10
    else
      return karte.wert - 5
    end
    
  end
  
  def blank_machen_anspielen(karte)
    if karte.trumpf?
      return - 100 * karte.wert
    elsif lange_farbe?(karte.farbe)
      return karte.wert
    else
      return -karte.wert
    end
  end

  def stich_abgeben_anspielen(karte)
    if karte.trumpf?
      return - 100 * karte.wert
    else
      return 5 - karte.wert
    end
  end

  def abgedeckt(auftrag)
    @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe).any? {|karte| karte.wert >= auftrag.karte.wert && karte.wert >= 7}
  end
  
  # wie gut eine Karte zum Anspielen geeignet ist
  def anspiel_wert_karte(karte)
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.karte == karte}
      #puts "#{karte} #{eigenen_unerfuellten_auftrag_anspielen(karte)} 1"
      return eigenen_unerfuellten_auftrag_anspielen(karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege.flatten.any? { |auftrag| auftrag.karte == karte}
      #puts "#{karte} #{anderen_unerfuellten_auftrag_anspielen(karte)} 2"
      return anderen_unerfuellten_auftrag_anspielen(karte)
    elsif ! @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.empty?
      #p @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)
      #puts "#{karte} #{auftrag_farbe_anspielen(karte)} 3"
      return auftrag_farbe_anspielen(karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].any? {|auftrag| ! abgedeckt(auftrag)}
      #puts "#{karte} #{blank_machen_anspielen(karte)} 4"
      return blank_machen_anspielen(karte)
    else
      #puts "#{karte} #{stich_abgeben_anspielen(karte)} 5"
      return stich_abgeben_anspielen(karte)
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

  def ist_auftrag_von_spieler?(karte:, spieler_index:)
    @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? { |auftrag| auftrag.karte == karte }
  end

  def ist_auftrag?(karte:)
    @spiel_informations_sicht.auftraege.each do |auftrag_liste|
      return true if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
    end
    false
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

  def spieler_index_von_auftrag(karte:)
    @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
      return spieler_index if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
    end
    raise 'Bitte diese Funktion nur verwenden, wenn es ein Auftrag ist'
  end

  def braucht_stich_selbst_wert(karte:, stich:)
    if ist_auftrag_von_spieler?(karte: karte, spieler_index: 0) && karte.schlaegt?(stich.staerkste_karte)
      # p "1"
      (12 * karte.wert) - 5
    elsif karte.schlaegt?(stich.staerkste_karte) && karte.trumpf?
      # p "2"
      72 + karte.wert
    elsif karte.schlaegt?(stich.staerkste_karte) && !ist_auftrag?(karte: karte)
      # p "3"
      8 * karte.wert
    else
      # p "4"
      -10_000
    end
  end

  def anderer_braucht_stich_wert(spieler_index:, karte:, stich:)
    if (stich.gespielte_karten.length + spieler_index >= @spiel_informations_sicht.anzahl_spieler) && karte.schlaegt?(stich.staerkste_karte)
      # p "5"
      - 10_000
    elsif ((karte.wert >= 7) || karte.trumpf?) && karte.schlaegt?(stich.staerkste_karte)
      # p "6"
      - 3_000 * (karte.wert - 6)
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: spieler_index)
      # p "7"
      100
    elsif karte.trumpf? && karte.schlaegt?(stich.staerkste_karte)
      # p "8"
      - 100 - karte.wert
    elsif karte.schlaegt?(stich.staerkste_karte)
      # p "9"
      - 10 - karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length.zero?
      # p "10"
      karte.wert
    else
      # p "11"
      - karte.wert
    end
  end

  def auftrags_karte_legen_wert(karte:, stich:)
    if karte.schlaegt?(stich.staerkste_karte) && (stich.gespielte_karten.length + spieler_index_von_auftrag(karte: karte) >= @spiel_informations_sicht.anzahl_spieler)
      # p "14"
      - 10_000
    elsif karte.schlaegt?(stich.staerkste_karte) && (karte.wert == 9)
      # p "15"
      - 7_000
    elsif karte.schlaegt?(stich.staerkste_karte) && (karte.wert >= 7)
      # p "16"
      - 30 * (karte.wert - 6)
    elsif karte.schlaegt?(stich.staerkste_karte)
      # p "17"
      10 - karte.wert
    elsif ist_auftrag_von_spieler?(karte: karte,
                                   spieler_index: stich.staerkste_gespielte_karte.spieler_index) && ((stich.staerkste_karte.wert > 6) || stich.staerkste_karte.trumpf?)
      # p "18"
      10_000
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: stich.staerkste_gespielte_karte.spieler_index)
      # p "19"
      (stich.staerkste_karte.wert - 5) * 1000
    elsif stich.gespielte_karten.length + spieler_index_von_auftrag(karte: karte) >= @spiel_informations_sicht.anzahl_spieler
      # p "20"
      - 10_000
    elsif stich.staerkste_karte.wert > 6
      # p "21"
      -3_000 * (stich.staerkste_karte.wert - 6)
    elsif stich.staerkste_karte.trumpf?
      # p "22"
      -9_000 - (200 * stich.staerkste_karte.wert)
    else
      # p "23"
      - stich.staerkste_karte.wert - 20
    end
  end

  def keine_auftraege_von_karten_farbe_wert(stich:, karte:)
    if @spiel_informations_sicht.unerfuellte_auftraege[0].length.positive? && karte.schlaegt?(stich.staerkste_karte) && karte.trumpf?
      # p "26"
      10 + karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].length.positive? && karte.schlaegt?(stich.staerkste_karte)
      # p "27"
      karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].length.positive? && karte.trumpf?
      # p "28"
      - 10 - karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].length.positive?
      # p "29"
      - karte.wert
    elsif !karte.schlaegt?(stich.staerkste_karte) && karte.trumpf?
      # p "30"
      10 + karte.wert
    elsif !karte.schlaegt?(stich.staerkste_karte)
      # p "31"
      karte.wert
    elsif karte.trumpf?
      # p "32"
      - 10 - karte.wert
    else
      # p "33"
      - karte.wert
    end
  end

  # wie gut eine Karte zum drauflegen geeignet ist
  def abspiel_wert_karte(karte, stich)
    wert = 0
    spieler_index = finde_auftrag(stich)
    if !spieler_index.nil? && spieler_index.zero?
      wert += braucht_stich_selbst_wert(karte: karte, stich: stich)
    elsif !spieler_index.nil?
      wert += anderer_braucht_stich_wert(spieler_index: spieler_index, karte: karte, stich: stich)
    elsif karte.schlaegt?(stich.staerkste_karte) && ist_auftrag_von_spieler?(karte: karte, spieler_index: 0)
      # p "12"
      wert += (6 * karte.wert) - 3
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: 0)
      # p "13"
      wert -= 10_000
    elsif ist_auftrag?(karte: karte)
      wert += auftrags_karte_legen_wert(karte: karte, stich: stich)
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length.zero? && !karte.schlaegt?(stich.staerkste_karte) && @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length.positive?
      # p "24"
      wert += karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length.zero? && @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length.positive?
      # p "25"
      wert -= karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length.zero?
      wert += keine_auftraege_von_karten_farbe_wert(stich: stich, karte: karte)
    elsif (@spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length) && karte.schlaegt?(stich.staerkste_karte)
      # p "34"
      wert += karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length
      # p "35"
      wert -= karte.wert
    else
      # p "36"
      wert += karte.wert
    end
    wert
  end

  def abspielen(stich, waehlbare_karten)
    # puts
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
