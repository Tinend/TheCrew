# coding: utf-8
# frozen_string_literal: true

require_relative 'stich'

# Verwaltet das Spiel. Lässt jeden Spieler jede Runde auf den Stich spielen
class Spiel
  def initialize(spieler:, richter:, spiel_information:, reporter:, statistiker:)
    @spieler = spieler
    @richter = richter
    @spiel_information = spiel_information
    @ausspiel_recht_index = @spiel_information.kapitaen_index
    @spieler.each(&:vorbereitungs_phase)
    @reporter = reporter
    @statistiker = statistiker
  end

  def start_situation_berichten
    @reporter.berichte_start_situation(karten: @spiel_information.karten, auftraege: @spiel_information.auftraege)
    @statistiker.beachte_neues_spiel(@spieler.length)
  end

  def kommunizieren
    @spieler.each_index.any? do |i|
      kommunikation = @spieler[i].waehle_kommunikation
      next unless kommunikation

      @spiel_information.kommuniziert(spieler_index: i, kommunikation: kommunikation)
      @reporter.berichte_kommunikation(spieler_index: i, kommunikation: kommunikation)
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
      spieler_index = (i + @ausspiel_recht_index) % @spieler.length
      spieler = @spieler[spieler_index]
      wahl = spieler.waehle_karte(stich.fuer_spieler(spieler_index: spieler_index,
                                                     anzahl_spieler: @spiel_information.anzahl_spieler))
      @spiel_information.karte_gespielt(spieler_index: spieler_index, karte: wahl)
      stich.legen(karte: wahl, spieler_index: spieler_index)
    end
    @spiel_information.stich_fertig(stich)
    @richter.stechen(stich)
    @reporter.berichte_stich(stich: stich, vermasselte_auftraege: @richter.vermasselt_letzter_stich,
                             erfuellte_auftraege: @richter.erfuellt_letzter_stich)
    @statistiker.beachte_stich
    @richter.alle_karten_ausgespielt if @spiel_information.existiert_blanker_spieler?
    @ausspiel_recht_index = stich.sieger_index
  end

  def spiele
    start_situation_berichten
    runde until @richter.gewonnen || @richter.verloren

    if @richter.spiel_ende_verloren?
      @reporter.berichte_verloren
      @statistiker.beachte_verloren
    else
      @reporter.berichte_gewonnen
      @statistiker.beachte_gewonnen
    end
    @reporter.berichte_spiel_statistiken(@statistiker.letztes_spiel_statistiken)
    @richter.resultat
  end
end
