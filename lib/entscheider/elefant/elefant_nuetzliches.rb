# coding: utf-8
# ein paar nützliche Funktionen, die an- und abspielen brauchen
module ElefantNuetzliches
  def karte_ist_auftrag_von(karte)
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrags_liste, index|
      return index if auftrags_liste.any? {|auftrag| auftrag.karte == karte}
    end
    nil
  end

  def finde_auftrag_in_stich(stich)
    stich.karten.each do |karte|
      @spiel_informations_sicht.auftraege.each_with_index do |auftrag_liste, spieler_index|
        return spieler_index if auftrag_liste.any? { |auftrag| auftrag.karte == karte }
      end
    end
    nil
  end

  def auftraege_mit_farbe_berechnen(farbe)
    @spiel_informations_sicht.unerfuellte_auftraege.collect {|auftrag_liste|
      auftrag_liste.count {|auftrag| auftrag.farbe == farbe}
    }
  end
end
