# coding: utf-8
# frozen_string_literal: true

require_relative 'stich'

# Verwaltet das Spiel. Lässt jeden Spieler jede Runde auf den Stich spielen
class Spiel
  def initialize(spieler:, richter:, spiel_information:)
    @spieler = spieler
    @richter = richter
    @spiel_information = spiel_information
    @ausspiel_recht_index = @spieler.find_index(&:faegt_an?)
    @spiel_information.setze_kapitaen(@ausspiel_recht_index)
  end

  def runde
    stich = Stich.new
    @spieler.length.times do |i|
      spieler = @spieler[(i + @ausspiel_recht_index) % @spieler.length]
      wahl = spieler.waehle_karte(stich)
      stich.legen(karte: wahl, spieler: spieler)
    end
    @spiel_information.stich_fertig(stich)
    @richter.stechen(stich)
    richter.alle_karten_ausgespielt if @spieler.any? { |spieler| !spieler.hat_karten? } && !@richter.gewonnen
    @ausspiel_recht_index = @spieler.find_index(&:faegt_an?)
  end
end
