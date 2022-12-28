# coding: utf-8
# frozen_string_literal: true

require_relative 'stich'

# Verwaltet das Spiel. Lässt jeden Spieler jede Runde auf den Stich spielen
class Spiel
  def initialize(spieler:, richter:)
    @spieler = spieler
    @richter = richter
    @ausspiel_recht_index = @spieler.find_index(&:faegt_an?)
  end

  def runde
    stich = Stich.new
    @spieler.length.times do |i|
      spieler = @spieler[(i + @ausspiel_recht_index) % @spieler.length]
      wahl = spieler.waehle_karte(stich)
      stich.legen(karte: wahl, spieler: spieler)
    end
    @spieler.each do |spieler|
      spieler.stich_fertig(stich)
    end
    @richter.stechen(stich)
    richter.alle_karten_ausgespielt if @spieler.any? { |spieler| !spieler.hat_karten? } && !@richter.gewonnen
    @ausspiel_recht_index = @spieler.find_index(&:faegt_an?)
  end
end
