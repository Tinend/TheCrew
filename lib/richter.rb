# frozen_string_literal: true

# Entscheidet, ob das Spiel gewonnen oder verloren ist
class Richter
  def initialize(spiel_information:)
    @verloren = false
    @gewonnen = false
    @spiel_information = spiel_information
    @erfuellt_letzter_stich = []
    @vermasselt_letzter_stich = []
  end

  attr_reader :gewonnen, :verloren, :erfuellt_letzter_stich, :vermasselt_letzter_stich
  
  def auftraege(spieler_index)
    @spiel_information.unerfuellte_auftraege[spieler_index]
  end

  def auftraege_anderer_spieler(spieler_index)
    @spiel_information.unerfuellte_auftraege[0...spieler_index].flatten +
      @spiel_information.unerfuellte_auftraege[spieler_index + 1..].flatten
  end

  def sieger_auftraege_erfuellen(stich)
    @erfuellt_letzter_stich = []
    auftraege(stich.sieger_index).each do |auftrag|
      stich.karten.each do |karte|
        auftrag.erfuellen(karte)
      end
      @erfuellt_letzter_stich.push(auftrag) if auftrag.erfuellt
    end
  end

  def sieger_auftraege_vermasseln(stich)
    @vermasselt_letzter_stich = []
    auftraege_anderer_spieler(stich.sieger_index).each do |auftrag|
      stich.karten.each do |karte|
        @vermasselt_letzter_stich.push(auftrag) if auftrag.karte == karte
      end
    end
  end

  def stechen(stich)
    sieger_auftraege_erfuellen(stich)
    sieger_auftraege_vermasseln(stich)
    @gewonnen = true if @spiel_information.alle_auftraege_erfuellt?
  end

  def alle_karten_ausgespielt
    @verloren = true
  end

  def spiel_ende_verloren?
    return false if @gewonnen
    return true if @verloren
    return false
  end

  def resultat
    if @gewonnen
      return :gewonnen
    elsif @verloren
      return :verloren
    end
    raise
  end
  
end
