# frozen_string_literal: true

# Entscheidet, ob das Spiel gewonnen oder verloren ist
class Richter
  def initialize
    @verloren = false
    @gewonnen = false
    @auftraege = []
    @erfuellt_letzter_stich = []
    @vermasselt_letzter_stich = []
  end

  attr_reader :gewonnen, :verloren, :erfuellt_letzter_stich, :vermasselt_letzter_stich

  def auftraege_erhalten(auftraege)
    @auftraege = auftraege
    @verloren = false
    @gewonnen = false
  end

  def sieger_auftraege_erfuellen(stich)
    @erfuellt_letzter_stich = []
    stich.sieger.auftraege.each do |auftrag|
      stich.karten.each do |karte|
        auftrag.erfuellen(karte)
      end
      @erfuellt_letzter_stich.push(auftrag) if auftrag.erfuellt && @auftraege.include?(auftrag)
    end
  end

  def sieger_auftraege_vermasseln(stich)
    @vermasselt_letzter_stich = []
    (@auftraege - stich.sieger.auftraege).each do |auftrag|
      stich.karten.each do |karte|
        @vermasselt_letzter_stich.push(auftrag) if auftrag.karte == karte
      end
    end
  end

  def stechen(stich)
    sieger_auftraege_erfuellen(stich)
    sieger_auftraege_vermasseln(stich)
    @auftraege.delete_if(&:erfuellt)
    return unless @auftraege.length.zero?

    @gewonnen = true
  end

  def alle_karten_ausgespielt
    @verloren = true
  end
end
