# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'rhinoceros_farbe'
require_relative 'rhinoceros_auftrag'
require_relative 'saeuger_auftrag_nehmer'

# Rennt geradewegs auf die Aufträge zu
# Analysiert Aufträge um sich einen Vorteil zu verschaffen.
class Rhinoceros < Entscheider
  include SaeugerAuftragNehmer

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end

  def anspielen(waehlbare_karten)
    waehlbare_karten.max_by { |karte| anspiel_wert_karte(karte) }
  end

  # wie gut eine Karte zum Anspielen geeignet ist
  def anspiel_wert_karte(karte)
    wert = @farben[karte.farbe].anspielen_wert
    wert += 10 if @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.karte == karte }
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.farbe == karte.farbe and auftrag.karte.wert <= karte.wert}
      wert += karte.wert * 2
    else
      wert -= karte.wert
    end
    wert
  end

  def hat_fremden_auftrag?(stich)
    stich.gespielte_karten.any? {|gespielte_karte|
      @spiel_informations_sicht.auftraege[1..].flatten.any?{|auftrag| auftrag.karte == gespielte_karte.karte}
    }
  end
  
  def hat_eigenen_auftrag?(stich)
    stich.gespielte_karten.any? {|gespielte_karte|
      @spiel_informations_sicht.auftraege[0].any?{|auftrag| auftrag.karte == gespielte_karte.karte}
    }
  end
  
  def ist_auftrag_von_spieler?(karte:, spieler_index:)
    @spiel_informations_sicht.unerfuellte_auftraege[spieler_index].any? { |auftrag| auftrag.karte == karte }
  end

  def ist_auftrag?(karte:)
    @spiel_informations_sicht.auftraege.each do |auftrag_liste|
      return true if auftrag_liste.any? {|auftrag| auftrag.karte == karte}
    end
    false
  end

  # Findet raus, wer einen Auftrag im Stich hat. Wenn niemand einen hat, gibt es 0 zurück
  def finde_auftrag(stich)
    stich.karten.each do |karte|
      @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
        return spieler_index if auftrag_liste.any? {|auftrag| auftrag.karte == karte}
      end
    end
    nil
  end

  def spieler_index_von_auftrag(karte:)
    @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
      return spieler_index if auftrag_liste.any? {|auftrag| auftrag.karte == karte}
    end
    raise "Bitte diese Funktion nur verwenden, wenn es ein Auftrag ist"
  end

  
  # wie gut eine Karte zum drauflegen geeignet ist
  def abspiel_wert_karte(karte, stich)
    wert = @farben[karte.farbe].abspiel_wert(stich) * 10
    spieler_index = finde_auftrag(stich)
    if spieler_index == 0 and ist_auftrag_von_spieler?(karte: karte, spieler_index: 0) and karte.schlaegt?(stich.staerkste_karte)
      #p "1"
      wert += 12 * karte.wert - 5
    elsif spieler_index == 0 and karte.schlaegt?(stich.staerkste_karte) and karte.trumpf?
      #p "2"
      wert += 72 + karte.wert
    elsif spieler_index == 0 and karte.schlaegt?(stich.staerkste_karte) and ! ist_auftrag?(karte: karte)
      #p "3"
      wert += 8 * karte.wert
    elsif spieler_index == 0
      #p "4"
      wert -= 10000
    elsif ! spieler_index.nil? and stich.gespielte_karten.length + spieler_index >= @spiel_informations_sicht.anzahl_spieler and karte.schlaegt?(stich.staerkste_karte)
      #p "5"
      wert -= 10_000
    elsif ! spieler_index.nil? and (karte.wert >= 7 or karte.trumpf?) and karte.schlaegt?(stich.staerkste_karte)
      #p "6"
      wert -= 3_000 * (karte.wert - 6)
    elsif ! spieler_index.nil? and ist_auftrag_von_spieler?(karte: karte, spieler_index: spieler_index)
      #p "7"
      wert += 100
    elsif ! spieler_index.nil? and karte.trumpf? and karte.schlaegt?(stich.staerkste_karte)
      #p "8"
      wert -= 100 + karte.wert
    elsif ! spieler_index.nil? and karte.schlaegt?(stich.staerkste_karte)
      #p "9"
      wert -= 10 + karte.wert
    elsif ! spieler_index.nil? and @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length == 0
      #p "10"
      wert += karte.wert
    elsif ! spieler_index.nil?
      #p "11"
      wert -= karte.wert
    elsif karte.schlaegt?(stich.staerkste_karte) and ist_auftrag_von_spieler?(karte: karte, spieler_index: 0)
      #p "12"
      wert += 6 * karte.wert - 3
    elsif ist_auftrag_von_spieler?(karte: karte, spieler_index: 0)
      #p "13"
      wert -= 10_000
    elsif karte.schlaegt?(stich.staerkste_karte) and ist_auftrag?(karte: karte) and stich.gespielte_karten.length + spieler_index_von_auftrag(karte: karte) >= @spiel_informations_sicht.anzahl_spieler
      #p "14"
      wert -= 10_000
    elsif karte.schlaegt?(stich.staerkste_karte) and ist_auftrag?(karte: karte) and karte.wert == 9
      #p "15"
      wert -= 7_000
    elsif karte.schlaegt?(stich.staerkste_karte) and ist_auftrag?(karte: karte) and karte.wert >= 7
      #p "16"
      wert -= 30 * (karte.wert - 6)
    elsif karte.schlaegt?(stich.staerkste_karte) and ist_auftrag?(karte: karte)
      #p "17"
      wert += 10 - karte.wert
    elsif ist_auftrag?(karte: karte) and ist_auftrag_von_spieler?(karte: karte, spieler_index: stich.staerkste_gespielte_karte.spieler_index) and (stich.staerkste_karte.wert > 6 or stich.staerkste_karte.trumpf?)
      #p "18"
      wert += 1_0000
    elsif ist_auftrag?(karte: karte) and ist_auftrag_von_spieler?(karte: karte, spieler_index: stich.staerkste_gespielte_karte.spieler_index)
      #p "19"
      wert += (stich.staerkste_karte.wert - 5) * 1000
    elsif ist_auftrag?(karte: karte) and stich.gespielte_karten.length + spieler_index_von_auftrag(karte: karte) >= @spiel_informations_sicht.anzahl_spieler
      #p "20"
      wert -= 10_000
    elsif ist_auftrag?(karte: karte) and stich.staerkste_karte.wert > 6
      #p "21"
      wert -= 3000 * (stich.staerkste_karte.wert - 6)
    elsif ist_auftrag?(karte: karte) and stich.staerkste_karte.trumpf?
      #p "22"
      wert -= 9000 + 200 * stich.staerkste_karte.wert
    elsif ist_auftrag?(karte: karte)
      #p "23"
      wert -= stich.staerkste_karte.wert + 20
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length == 0 and ! karte.schlaegt?(stich.staerkste_karte) and @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length > 0
      #p "24"
      wert += karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length == 0 and @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length > 0
      #p "25"
      wert -= karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0 and @spiel_informations_sicht.unerfuellte_auftraege[0].length > 0 and karte.schlaegt?(stich.staerkste_karte) and karte.trumpf?
      #p "26"
      wert += 10 + karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0 and @spiel_informations_sicht.unerfuellte_auftraege[0].length > 0 and karte.schlaegt?(stich.staerkste_karte)
      #p "27"
      wert += karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0 and @spiel_informations_sicht.unerfuellte_auftraege[0].length > 0 and karte.trumpf?
      #p "28"
      wert -= 10 + karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0 and @spiel_informations_sicht.unerfuellte_auftraege[0].length > 0
      #p "29"
      wert -= karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0 and ! karte.schlaegt?(stich.staerkste_karte) and karte.trumpf?
      #p "30"
      wert += 10 + karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0 and ! karte.schlaegt?(stich.staerkste_karte)
      #p "31"
      wert += karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0 and karte.trumpf?
      #p "32"
      wert -= 10 + karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == 0
      #p "33"
      wert -= karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length and karte.schlaegt?(stich.staerkste_karte)
      #p "34"
      wert += karte.wert
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.length == @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length
      #p "35"
      wert -= karte.wert
    else
      #p "36"
      wert += karte.wert
    end
    wert
  end

  def abspielen(stich, waehlbare_karten)
    #puts
    waehlbare_karten.max_by { |karte| abspiel_wert_karte(karte, stich) }
  end

  def waehle_karte(stich, waehlbare_karten)
    if stich.karten.length.zero?
      anspielen(waehlbare_karten)
    else
      abspielen(stich, waehlbare_karten)
    end
  end

  def vorbereitungs_phase
    farben_erstellen
    auftraege_erstellen
    auftraege_analysieren
  end

  def farben_erstellen
    @farben = Farbe::NORMALE_FARBEN.to_h do |farbe|
      [farbe, RhinocerosFarbe.new(
        farbe: farbe,
        anzahl: 9,
        eigene_anzahl: karten.count do |k|
          k.farbe == farbe
        end,
        spiel_informations_sicht: @spiel_informations_sicht
      )]
    end
    @farben[Farbe::RAKETE] = RhinocerosFarbe.new(
      farbe: Farbe::RAKETE,
      anzahl: 4,
      eigene_anzahl: karten.count(&:trumpf?),
      spiel_informations_sicht: @spiel_informations_sicht
    )
    @farben.each do |farbe_farbe|
      farbe_farbe[1].eigene_karten_erhalten(karten.select { |karte| karte.farbe == farbe_farbe[1].farbe })
    end
  end

  def auftraege_erstellen
    @auftraege = []
    @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
      @auftraege += auftrag_liste.collect.with_index do |auftrag, wahl_index|
        RhinocerosAuftrag.new(
          auftrag: auftrag,
          spieler_index: spieler_index,
          wahl_index: wahl_index,
          hat_selber: karten.include?(auftrag.karte)
        )
      end
    end
  end

  def auftraege_analysieren
    @auftraege.each do |auftrag|
      @farben[auftrag.farbe].auftrag_erhalten(auftrag)
    end
    @farben.each do |farbe_farbe|
      farbe_farbe[1].analysieren
    end
  end
end
