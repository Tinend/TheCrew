# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative '../farbe'
require_relative 'rhinoceros_farbe'
require_relative 'rhinoceros_auftrag'
require_relative 'saeuger_auftrag_nehmer'
require_relative 'spiel_informations_sicht_benutzender'

# Rennt geradewegs auf die Aufträge zu
# Analysiert Aufträge um sich einen Vorteil zu verschaffen.
class Rhinoceros < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender

  def anspielen(waehlbare_karten)
    waehlbare_karten.max_by { |karte| anspiel_wert_karte(karte) }
  end

  # wie gut eine Karte zum Anspielen geeignet ist
  def anspiel_wert_karte(karte)
    wert = @farben[karte.farbe].anspielen_wert
    wert += 10 if @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.karte == karte }
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? do |auftrag|
         (auftrag.farbe == karte.farbe) && (auftrag.karte.wert <= karte.wert)
       end
      wert += karte.wert * 2
    else
      wert -= karte.wert
    end
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
    wert = @farben[karte.farbe].abspiel_wert(stich) * 10
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
