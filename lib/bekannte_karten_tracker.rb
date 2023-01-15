# coding: utf-8
# frozen_string_literal: true

# Klasse, die dafür zuständig ist, anhand gegangener Karten und Kommunikation
# einzuschränken, wer welche Karten haben könnte.
class BekannteKartenTracker
  def initialize(spiel_informations_sicht:)
    @spiel_informations_sicht = spiel_informations_sicht
    @sichere_karten = anfangs_sichere_karten
    @moegliche_karten = anfangs_moegliche_karten

    beachte_kommunikationen
    beachte_blankheit
    stabilisiere_karten_information
  end

  attr_reader :sichere_karten, :moegliche_karten

  def anfangs_moegliche_karten
    kapitaen_index = @spiel_informations_sicht.kapitaen_index
    ungegangene_karten = Karte.alle - @spiel_informations_sicht.stiche.flat_map(&:karten)
    Array.new(@spiel_informations_sicht.anzahl_spieler) do |i|
      case i
      when 0
        @spiel_informations_sicht.karten.dup
      when kapitaen_index
        ungegangene_karten - @spiel_informations_sicht.karten
      else
        ungegangene_karten - @spiel_informations_sicht.karten - [Karte.max_trumpf]
      end
    end
  end

  def anfangs_sichere_karten
    kapitaen_index = @spiel_informations_sicht.kapitaen_index
    Array.new(@spiel_informations_sicht.anzahl_spieler) do |i|
      case i
      when 0
        @spiel_informations_sicht.karten.dup
      when kapitaen_index
        [Karte.max_trumpf]
      else
        []
      end
    end
  end

  def karten_drueber(karte)
    (karte.wert + 1..karte.farbe.max_wert).map { |w| Karte.new(farbe: karte.farbe, wert: w) }
  end

  def karten_drunter(karte)
    (karte.farbe.min_wert...karte.wert).map { |w| Karte.new(farbe: karte.farbe, wert: w) }
  end

  def ausgeschlossene_karten(kommunikation)
    if kommunikation.hoechste?
      karten_drueber(kommunikation.karte)
    elsif kommunikation.tiefste?
      karten_drunter(kommunikation.karte)
    elsif kommunikation.einzige?
      karten_drueber(kommunikation.karte) + karten_drunter(kommunikation.karte)
    else
      raise
    end
  end
  
  def hat_nachher_andere_karte_dieser_farbe_gespielt(spieler_index, kommunikation)
    @spiel_informations_sicht.stiche[kommunikation.gegangene_stiche..].any? do |s, _i|
      s.gespielte_karten.any? do |k|
        k.karte != kommunikation.karte &&
          k.karte.farbe == kommunikation.karte.farbe && k.spieler_index == spieler_index
      end
    end
  end

  def eine_dieser_karten_ist_sicher_drinnen(spieler_index, kommunikation)
    return [] if hat_nachher_andere_karte_dieser_farbe_gespielt(spieler_index, kommunikation)
    
    if kommunikation.hoechste?
      karten_drunter(kommunikation.karte)
    elsif kommunikation.tiefste?
      karten_drueber(kommunikation.karte)
    elsif kommunikation.einzige?
      []
    else
      raise
    end
  end
  
  def beachte_blankheit
    @spiel_informations_sicht.stiche.each do |s|
      s.gespielte_karten.each do |g|
        # Spieler hat nicht angegeben.
        @moegliche_karten[g.spieler_index].delete_if { |k| k.farbe == s.farbe } if g.karte.farbe != s.farbe
      end
    end
  end
  
  def beachte_kommunikationen
    @spiel_informations_sicht.kommunikationen.each_with_index do |kommunikation, spieler_index|
      next unless kommunikation
      
      beachte_kommunikation(spieler_index, kommunikation)
    end
  end
  
  def beachte_kommunikation(spieler_index, kommunikation)
    return if spieler_index == 0
    @moegliche_karten[spieler_index] -= ausgeschlossene_karten(kommunikation)
    @sichere_karten[spieler_index].push(kommunikation.karte)
    vielleicht_eindeutige_karte = eine_dieser_karten_ist_sicher_drinnen(spieler_index,
                                                                        kommunikation) &
                                  @moegliche_karten[spieler_index]
    @sichere_karten[spieler_index].push(vielleicht_eindeutige_karte.first) if vielleicht_eindeutige_karte.length == 1
    @sichere_karten[spieler_index].uniq!
  end
  
  def stabilisiere_karten_information
    while entferne_andere_sichere_karten || beachte_eindeutige_besitzer || beachte_eindeutige_karten; end
  end
  
  def beachte_eindeutige_karten
    was_veraendert = false
    @moegliche_karten.each_with_index do |m, i|
      if m.length > @sichere_karten[i].length && m.length == @spiel_informations_sicht.anzahl_karten(spieler_index: i)
        was_veraendert = true
        @sichere_karten[i] = m
      end
    end
    was_veraendert
  end
  
  def entferne_andere_sichere_karten
    was_veraendert = false
    @sichere_karten.each_with_index do |s, i|
      @moegliche_karten.each_with_index do |m, j|
        next if i == j
        
        reduziert = m - s
        next unless reduziert.length < m.length
        
        was_veraendert = true
        @moegliche_karten[j] = reduziert
      end
    end
    was_veraendert
  end

  def beachte_eindeutige_besitzer
    besitzer = {}
    besitzer.default_proc = proc { |hash, key| hash[key] = [] }
    
    @moegliche_karten.each_with_index do |m, i|
      (m - @sichere_karten[i]).each do |k|
        besitzer[k].push(i)
      end
    end
    
    was_veraendert = false
    besitzer.each do |karte, spieler_indizes|
      next unless spieler_indizes.length == 1
      
      was_veraendert = true
      @sichere_karten[spieler_indizes.first].push(karte)
    end
    was_veraendert
  end
  
  def moegliche_karten_von_spieler_mit_farbe(spieler_index:, farbe:)
    @spiel_informations_sicht.moegliche_karten(spieler_index).select {|karte| karte.farbe == farbe}
  end
end
