# frozen_string_literal: true

# Klasse, die dafür zuständig ist, anhand gegangener Karten und Kommunikation
# einzuschränken, wer welche Karten haben könnte.
class BekannteKartenTracker
  def initialize(spiel_informations_sicht:)
    @spiel_informations_sicht = spiel_informations_sicht
    @sichere_karten = anfangs_sichere_karten
    @moegliche_karten = anfangs_moegliche_karten

    @spiel_informations_sicht.kommunikationen.each_with_index do |kommunikation, spieler_index|
      next unless kommunikation

      kommuniziere(spieler_index, kommunikation)
    end
  end

  attr_reader :sichere_karten, :moegliche_karten

  def anfangs_moegliche_karten
    kapitaen_index = @spiel_informations_sicht.kapitaen_index
    ungegangene_karten = Karte.alle - @spiel_informations_sicht.stiche.flat_map(&:karten)
    Array.new(@spiel_informations_sicht.anzahl_spieler) do |i|
      case i
      when 0
        @spiel_informations_sicht.karten
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
        @spiel_informations_sicht.karten
      when kapitaen_index
        [Karte.max_trumpf]
      else
        []
      end
    end
  end

  def karten_drueber(karte)
    (karte.wert + 1..farbe.max_wert).map { |w| Karte.new(farbe: karte.farbe, wert: w) }
  end

  def karten_drunter(karte)
    (karte.farbe.min_wert...kommunikation.karte.wert).map { |w| Karte.new(farbe: karte.farbe, wert: w) }
  end

  def ausgeschlossene_karten(kommunikation)
    if kommunikation.karte.hoechste?
      karten_drunter(kommunikation.karte)
    elsif kommunikation.karte.tiefste?
      karten_drueber(kommunikation.karte)
    elsif kommunikation.karte.einzige?
      karten_drueber(kommunikation.karte) + karten_drunter(kommunikation.karte)
    else
      raise
    end
  end

  def hat_nachher_andere_karte_dieser_farbe_gespielt(spieler_index, kommunikation)
    @spiel_informations_sicht.stiche.with_index.any? do |s, i|
      i >= kommunikation.gegangene_stiche &&
        s.gespielte_karten.any? do |k|
          k.karte != kommunikation.karte &&
            k.karte.farbe == kommunikation.karte.farbe && k.spieler_index == spieler_index
        end
    end
  end

  def eine_dieser_karten_ist_sicher_drinnen(spieler_index, kommunikation)
    return [] if hat_nachher_andere_karte_dieser_farbe_gespielt(spieler_index, kommunikation)

    if kommunikation.karte.hoechste?
      karten_drueber(kommunikation.karte)
    elsif kommunikation.karte.tiefste?
      karten_drunter(kommunikation.karte)
    elsif kommunikation.karte.einzige?
      []
    else
      raise
    end
  end

  def kommuniziere(spieler_index, kommunikation)
    @sichere_karten[spieler_index] -= ausgeschlossene_karten(kommunikation)
    @moegliche_karten[spieler_index] -= ausgeschlossene_karten(kommunikation)
    @sichere_karten[spieler_index].push(kommunikation.karte)
    vielleicht_eindeutige_karte = eine_dieser_karten_ist_sicher_drinnen(spieler_index,
                                                                        kommunikation) &
                                  @moegliche_karten[spieler_index]
    @sichere_karten[spieler_index].push(vielleicht_eindeutige_karte) if vielleicht_eindeutige_karte.length == 1
    @sichere_karten[spieler_index].uniq!
    @moegliche_karten.each_with_index do |e, i|
      next if i == spieler_index

      @sichere_karten[spieler_index].each { |k| e.delete(k) }
    end
  end
end
