# coding: utf-8
# frozen_string_literal: true

require_relative 'schimpansen_hand'
require_relative 'schimpansen_karten_wert_berechner'

# Funktion zum Legen einer Karte für den Schimpansen
module SchimpanseLegen
  def waehle_karte(stich, waehlbare_karten)
    haende = Array.new(anzahl_spieler) do |spieler_index|
      SchimpansenHand.new(stich: stich, spieler_index: spieler_index,
                          spiel_informations_sicht: @spiel_informations_sicht)
    end
    waehlbare_karten.max_by do |karte|
      bewerter = SchimpansenKartenWertBerechner.new(
        spiel_informations_sicht: @spiel_informations_sicht,
        stich: stich,
        karte: karte,
        haende: haende
      )
      bewerter.wert
    end
  end

  def anzahl_spieler
    @spiel_informations_sicht.anzahl_spieler
  end
end
