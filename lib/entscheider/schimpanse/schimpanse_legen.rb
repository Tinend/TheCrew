module SchimpanseLegen
  def waehle_karte(stich, waehlbare_karten)
    haende = Array.new(anzahl_spieler) {|spieler_index|
      SchimpansenHand.new(spieler_index: spieler_index, spiel_informations_sicht: spiel_informations_sicht)
    }
    waehlbare_karten.max_by {|karte|
      bewerter = SchimpansenKartenWertBerechner.new(
        spiel_informations_sicht: @spiel_informations_sicht,
        stich: stich,
        karte: karte,
        haende: haende
      )
      bewerter.wert
    }
  end
end
