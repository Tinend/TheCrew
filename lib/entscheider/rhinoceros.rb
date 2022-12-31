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
    waehlbare_karten.sort_by!{|karte| anspiel_wert_karte(karte)}
    waehlbare_karten[-1]
  end

  def anspiel_wert_karte(karte)
    wert = @farben[karte.farbe].anspielen_wert * 10
    wert += 10 if @spiel_informations_sicht.unerfuellte_auftraege[0].any?{|auftrag| auftrag.karte == karte}
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any?{|auftrag| auftrag.farbe == karte.farbe}
      wert += karte.wert
    else
      wert -= karte.wert
    end
    wert
  end

  def abspielen(stich, waehlbare_karten)
    waehlbare_karten.sort_by!{|karte| anspiel_wert_karte(karte)}
    waehlbare_karten[-1]    
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
    @farben = Farbe::NORMALE_FARBEN.to_h { |farbe|
      [farbe, RhinocerosFarbe.new(farbe: farbe, anzahl: 9, eigene_anzahl: karten.count {|k| k.farbe == farbe}, spiel_informations_sicht: @spiel_informations_sicht)]
    }
    @farben[Farbe::RAKETE] = RhinocerosFarbe.new(
      farbe: Farbe::RAKETE,
      anzahl: 4,
      eigene_anzahl: karten.count {|k| k.trumpf?},
      spiel_informations_sicht: @spiel_informations_sicht
    )
    @farben.each do |farbe_farbe|
      farbe_farbe[1].eigene_karten_erhalten(karten.select {|karte| karte.farbe == farbe_farbe[1].farbe})
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
