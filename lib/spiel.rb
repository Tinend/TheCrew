# coding: utf-8
# frozen_string_literal: true

require_relative 'stich'

# Verwaltet das Spiel. Lässt jeden Spieler jede Runde auf den Stich spielen
class Spiel
  def initialize(spieler:, richter:, spiel_information:)
    @spieler = spieler
    @richter = richter
    @spiel_information = spiel_information
    @ausspiel_recht_index = @spieler.find_index(&:faengt_an?)
    @spiel_information.setze_kapitaen(@ausspiel_recht_index)
    starthand_zeigen
  end

  def starthand_zeigen
    @spieler.each_with_index do |spieler, index|
      puts "Spieler #{index + 1}"
      puts "Hand: #{spieler}"
      puts "Aufträge: #{@spiel_information.auftraege[index].reduce('') { |start, auftrag| start + auftrag.karte.to_s }}"
      puts
    end
  end

  def kommunizieren
    @spieler.each_index.any? do |i|
      kommunikation = @spieler[i].waehle_kommunikation
      next unless kommunikation

      @spiel_information.kommuniziere(i, kommunikation)
      true
    end
  end

  # Immer wenn jemand kommuniziert, kriegen andere die Gelegenheit, nochmal zu kommunizieren. Bis keiner mehr will.
  def iterativ_kommunizieren
    while kommunizieren; end
  end

  def runde
    iterativ_kommunizieren
    stich = Stich.new
    @spieler.each_index do |i|
      spieler = @spieler[(i + @ausspiel_recht_index) % @spieler.length]
      wahl = spieler.waehle_karte(stich)
      stich.legen(karte: wahl, spieler: spieler)
    end
    @spiel_information.stich_fertig(stich)
    @richter.stechen(stich)
    @richter.alle_karten_ausgespielt if @spieler.any? { |spieler| !spieler.hat_karten? } && !@richter.gewonnen
    @ausspiel_recht_index = @spieler.find_index(stich.sieger)
  end
end
