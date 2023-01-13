# coding: utf-8
# Berechnet wie gut es ist, eine bestimmte Karte zu legen
# Für den Schimpansen gemacht
class SchimpansenKartenWertBerechner
  def initiative(spielspiel_informations_sicht_informations_sicht:, stich:, karte:)
    @karte = karte
    @spiel_informations_sicht = spiel_informations_sicht
    @stich = stich
    @min_auftraege = Array.new(@spiel_informations_sicht.anzahl_spieler, 0.0)
    @max_auftraege = Array.new(@spiel_informations_sicht.anzahl_spieler, 0.0)    
    @min_sieges_wkeit = Array.new(@spiel_informations_sicht.anzahl_spieler, 0.0)
    @max_sieges_wkeit = Array.new(@spiel_informations_sicht.anzahl_spieler, 0.0)    
  end

  def wert_berechnen
  end

  def auftraege_aus_stich_lesen
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrag_liste, spieler_index|
      @stich.karten.each do |karte|
        if auftrag_liste.any? {|auftrag| auftrag.karte == karte}
          @min_auftraege[spieler_index] += 1
          @max_auftraege[spieler_index] += 1
        end
      end
      if auftrag_liste.any? {|auftrag| auftrag.karte == @karte}
        @min_auftraege[spieler_index] += 1
        @max_auftraege[spieler_index] += 1
      end      
    end
  end
end
