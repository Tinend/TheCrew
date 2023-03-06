# coding: utf-8
# frozen_string_literal: true

# Module für das Anspielen vom Rhinoceros
module RhinocerosAnspielen
  def anspielen(waehlbare_karten)
    waehlbare_karten.max_by { |karte| anspiel_wert_karte(karte) }
  end

  # wie gut eine Karte zum Anspielen geeignet ist
  def anspiel_wert_karte(karte)
    # puts "#{karte} 1"
    if @spiel_informations_sicht.unerfuellte_auftraege.flatten.any? { |auftrag| auftrag.karte == karte }
      unerfuellten_auftrag_anspielen(karte)
    elsif !@spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe).flatten.empty?
      auftrag_farbe_anspielen(karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| !abgedeckt(auftrag) }
      blank_machen_anspielen(karte)
    else
      stich_abgeben_anspielen(karte)
    end
  end

  def anderen_unerfuellten_auftrag_anspielen(karte)
    # puts "#{karte} 2"
    if karte.wert <= 7
      100 - (karte.wert * 10)
    else
      6900 - (1000 * karte.wert)
    end
  end

  def abgedeckt(auftrag)
    @spiel_informations_sicht.karten_mit_farbe(auftrag.farbe).any? do |karte|
      karte.wert >= auftrag.karte.wert && karte.wert >= 7
    end
  end

  def unerfuellten_auftrag_anspielen(karte)
    # puts "#{karte} 3"
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? { |auftrag| auftrag.karte == karte }
      eigenen_unerfuellten_auftrag_anspielen(karte)
    else
      anderen_unerfuellten_auftrag_anspielen(karte)
    end
  end

  def lange_farbe?(farbe)
    karten = Karte.alle_mit_farbe(farbe)
    karten.reject { |karte| @spiel_informations_sicht.ist_gegangen?(karte) }
    karten.length < lange_farbe_schranke(farbe)
  end

  def lange_farbe_schranke(farbe)
    (@spiel_informations_sicht.karten_mit_farbe(farbe).length * @spiel_informations_sicht.anzahl_spieler) - 1
  end

  def anspielen_auftrag_holen(karte)
    # puts "#{karte} 4"
    if @spiel_informations_sicht.unerfuellte_auftraege[0].any? do |auftrag|
         (auftrag.farbe == karte.farbe) && (auftrag.karte.wert <= karte.wert)
       end
      (100 * karte.wert) - 490
    else
      karte.wert - 100
    end
  end

  def eigenen_unerfuellten_auftrag_anspielen(karte)
    # puts "#{karte} 5"
    if karte.wert >= 6
      karte.wert * 1000
    else
      karte.wert
    end
  end

  # rubocop:disable Lint/DuplicateBranch
  def auftrag_farbe_mit_holbarem_auftrag_anspielen(karte)
    # puts "#{karte} 6"
    anspielen_auftrag_holen(karte)
  end

  def auftrag_farbe_anspielen(karte)
    # puts "#{karte} 7"
    if !@spiel_informations_sicht.unerfuellte_auftraege_nicht_auf_eigener_hand_mit_farbe(karte.farbe)[0].empty?
      auftrag_farbe_mit_holbarem_auftrag_anspielen(karte)
    elsif @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].empty?
      30 - karte.wert
    elsif !@spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[1..].flatten.empty?
      30 - karte.wert
    elsif lange_farbe?(karte.farbe)
      karte.wert + 10
    else
      karte.wert - 5
    end
  end
  # rubocop:enable Lint/DuplicateBranch:

  def blank_machen_anspielen(karte)
    # puts "#{karte} 8"
    if karte.trumpf?
      - 100 * karte.wert
    elsif lange_farbe?(karte.farbe)
      karte.wert
    else
      -karte.wert
    end
  end

  def stich_abgeben_anspielen(karte)
    # puts "#{karte} 9"
    if karte.trumpf?
      - 100 * karte.wert
    else
      5 - karte.wert
    end
  end
end
