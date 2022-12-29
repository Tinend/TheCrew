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
  end

  def stechen(stich)
    @erfuellt_letzter_stich = []
    @vermasselt_letzter_stich = []
    stich.sieger.auftraege.each do |auftrag|
      stich.karten.each do |karte|
        auftrag.erfuellen(karte)
      end
      @erfuellt_letzter_stich.push(auftrag) if auftrag.erfuellt && @auftraege.include?(auftrag)
    end
    (@auftraege - stich.sieger.auftraege).each do |auftrag|
      stich.karten.each do |karte|
        @vermasselt_letzter_stich.push(auftrag) if auftrag.karte == karte
      end
    end
    @auftraege.delete_if(&:erfuellt)
    return unless @auftraege.length.zero?

    @gewonnen = true
  end

  def alle_karten_ausgespielt
    @verloren = true
  end
end
