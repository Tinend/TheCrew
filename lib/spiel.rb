# coding: utf-8
# frozen_string_literal: true

require_relative 'stich'

# Verwaltet das Spiel. Lässt jeden Spieler jede Runde auf den Stich spielen
class Spiel
  def initialize(spieler:, richter:, spiel_information:, ausgeben: true)
    @spieler = spieler
    @richter = richter
    @spiel_information = spiel_information
    @ausspiel_recht_index = @spiel_information.kapitaen_index
    @spieler.each(&:vorbereitungs_phase)
    starthand_zeigen if ausgeben
  end

  def starthand_zeigen
    @spieler.each_index do |index|
      puts "Spieler #{index + 1}"
      puts "Hand: #{@spiel_information.karten[index].sort.reverse.join(' ')}"
      puts "Aufträge: #{@spiel_information.auftraege[index].sort.reverse.join(' ')}"
      puts
    end
  end

  def kommunizieren(ausgeben)
    @spieler.each_index.any? do |i|
      kommunikation = @spieler[i].waehle_kommunikation
      next unless kommunikation

      @spiel_information.kommuniziert(spieler_index: i, kommunikation: kommunikation)
      if ausgeben
        puts "Spieler #{i + 1} kommuniziert, dass #{kommunikation.karte} seine #{kommunikation.art} " \
             "#{kommunikation.karte.farbe.name}e ist."
      end
      true
    end
  end

  # Immer wenn jemand kommuniziert, kriegen andere die Gelegenheit, nochmal zu kommunizieren. Bis keiner mehr will.
  def iterativ_kommunizieren(ausgeben)
    while kommunizieren(ausgeben); end
  end

  def stich_ausgeben(stich)
    puts "Spieler #{stich.sieger_index + 1} holt den Stich."
    puts stich.to_s
    if @richter.vermasselt_letzter_stich != []
      vermasselt = @richter.vermasselt_letzter_stich.join(' ')
      puts "Folgender Auftrag wurde nicht erfüllt: #{vermasselt}" if @richter.vermasselt_letzter_stich.length == 1
      puts "Folgende Aufträge wurden nicht erfüllt: #{vermasselt}" if @richter.vermasselt_letzter_stich.length > 1
    end
    return unless @richter.erfuellt_letzter_stich != []

    erfuellt = @richter.erfuellt_letzter_stich.join(' ')
    puts "Folgender Auftrag wurde erfüllt: #{erfuellt}" if @richter.erfuellt_letzter_stich.length == 1
    puts "Folgende Aufträge wurden erfüllt: #{erfuellt}" if @richter.erfuellt_letzter_stich.length > 1
  end

  def runde(ausgeben: true)
    iterativ_kommunizieren(ausgeben)
    stich = Stich.new
    @spieler.each_index do |i|
      spieler_index = (i + @ausspiel_recht_index) % @spieler.length
      spieler = @spieler[spieler_index]
      wahl = spieler.waehle_karte(stich.fuer_spieler(spieler_index: i,
                                                     anzahl_spieler: @spiel_information.anzahl_spieler))
      @spiel_information.karte_gespielt(spieler_index: spieler_index, karte: wahl)
      stich.legen(karte: wahl, spieler_index: spieler_index)
    end
    @spiel_information.stich_fertig(stich)
    @richter.stechen(stich)
    stich_ausgeben(stich) if ausgeben
    @richter.alle_karten_ausgespielt if @spiel_information.existiert_blanker_spieler?
    @ausspiel_recht_index = stich.sieger_index
  end
end
