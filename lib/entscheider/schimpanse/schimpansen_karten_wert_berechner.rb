# coding: utf-8
# Berechnet wie gut es ist, eine bestimmte Karte zu legen
# Für den Schimpansen gemacht
class SchimpansenKartenWertBerechner
  def initiative(spiel_informations_sicht:, stich:, karte:, haende:)
    @karte = karte
    @spiel_informations_sicht = spiel_informations_sicht
    @stich = stich
    @min_auftraege_wkeit = Array.new(anzahl_spieler, 0.0)
    @max_auftraege_wkeit = Array.new(anzahl_spieler, 0.0)    
    @min_sieges_wkeit = Array.new(anzahl_spieler, 0.0)
    @max_sieges_wkeit = Array.new(anzahl_spieler, 0.0)    
    @moegliche_auftraege = @spiel_informations_sicht.unerfuellte_auftraege
    @moegliche_auftraege.each do |auftrag_liste|
      auftrag_liste.reject! {|auftrag|
        auftrag.karte == @karte || @stich.karten.any?{|stich_karte| auftrag.karte == stich_karte}
      }
    end
    @haende = haende
  end

  def wert
  end

  # Liest die Aufträge aus dem Stich, wenn diese Karte gelegt wird
  def auftraege_aus_stich_lesen
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrag_liste, spieler_index|
      @stich.karten.each do |karte|
        if auftrag_liste.any? {|auftrag| auftrag.karte == karte}
          @min_auftraege_wkeit[spieler_index] = 1
          @max_auftraege_wkeit[spieler_index] = 1
        end
      end
      if auftrag_liste.any? {|auftrag| auftrag.karte == @karte}
        @min_auftraege_wkeit[spieler_index] = 1
        @max_auftraege_wkeit[spieler_index] = 1
      end
    end
  end

  def anzahl_spieler
    @spiel_informations_sicht.anzahl_spieler
  end

  # Die Aufträge aus dem Stich und von der Karte werden bereits zuvor gezählt
  def auftraege_berechnen
    max_spieler_index = anzahl_spieler - 1 - @stich.karten.length
    (1..max_spieler_index).each do |spieler_index|
      min_auftraege_von_spieler_berechnen(spieler_index: spieler_index)
    end
  end

  def auftraege_von_spieler_berechnen(spieler_index:)
    (0..anzahl_spieler - 1).each do |auftrag_spieler_index|
      min_auftraege_von_spieler_fuer_spieler_berechnen(
        karten_spieler_index: karten_spieler_index,
        auftrag_spieler_index: auftrag_spieler_index
      )
    end
  end

  def auftraege_von_spieler_fuer_spieler_berechnen(karten_spieler_index:, auftrag_spieler_index:)
    min_wkeit = @haende[karten_spieler_index].min_auftraege_lege_wkeit(spieler_index:)
    @min_auftraege_wkeit[spieler_index] = 1 - (1 - @min_auftraege_wkeit[spieler_index])(1 - min_wkeit)
    max_wkeit = @haende[karten_spieler_index].min_auftraege_lege_wkeit(spieler_index:)
    @min_auftraege_wkeit[spieler_index] = 1 - (1 - @min_auftraege_wkeit[spieler_index])(1 - min_wkeit)
  end
end
