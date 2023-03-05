# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'

# Entscheider, der immer zufällig entschiedet, was er spielt.
class Mensch < Entscheider
  include SpielInformationsSichtBenutzender

  def kommuniziert?
    @zufalls_generator.rand(karten.length).zero?
  end

  def zeige_zustand
    puts
    kommunikation_ausgeben
    letzten_stich_ausgeben
    auftraege_ausgeben
    hand_ausgeben
  end

  def kommunikation_ausgeben
    @spiel_informations_sicht.kommunikationen.each_with_index do |kommunikation, spieler_index|
      next if kommunikation.nil? || spieler_index.zero?

      puts "Spieler #{spieler_index}:"
      case kommunikation.art
      when :hoechste
        puts " <= #{kommunikation.karte}"
      when :tiefste
        puts " >= #{kommunikation.karte}"
      else
        puts " = #{kommunikation.karte}"
      end
    end
  end

  def letzten_stich_ausgeben
    puts
    return if @spiel_informations_sicht.stiche.empty?

    puts 'letzter Stich:'
    stich = @spiel_informations_sicht.stiche[-1]
    stich.karten.each do |karte|
      print "#{karte} "
    end
    puts
  end

  def auftraege_ausgeben
    puts
    puts 'Unerfuellte Auftraege:'
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrag_array, spieler_index|
      next if auftrag_array.empty?

      if spieler_index.zero?
        puts 'Du:'
      else
        puts "Spieler #{spieler_index}:"
      end
      auftrag_array_ausgeben(auftrag_array)
    end
  end

  def auftrag_array_ausgeben(auftrag_array)
    auftrag_array.each do |auftrag|
      print "#{auftrag.karte} "
    end
    puts
  end

  def hand_ausgeben
    puts 'Deine Hand:'
    @spiel_informations_sicht.karten.sort.reverse.each do |karte|
      print "#{karte} "
    end
    puts
  end

  def kommunizierbares_ausgeben(kommunizierbares)
    kommunizierbares.each_with_index do |kommunikation, index|
      art = case kommunikation.art
            when :hoechste
              'hoechste'
            when :tiefste
              'tiefste'
            else
              'einzige'
            end
      puts "#{index + 1} = Karte #{kommunikation.karte} als #{art}"
    end
  end

  def waehle_kommunikation(kommunizierbares)
    puts
    zeige_zustand
    puts
    puts 'Was willst du kommunizieren?'
    puts '0 = nicht kommunizieren'
    kommunizierbares_sortiert = kommunizierbares.sort_by(&:karte)
    kommunizierbares_sortiert.reverse!
    kommunizierbares_ausgeben(kommunizierbares_sortiert)
    wahl = -1
    wahl = gets.to_i until (wahl >= 0) && (wahl <= kommunizierbares.length)
    kommunizierbares_sortiert[wahl - 1] if wahl != 0
  end

  def waehl_auftrag(auftraege)
    puts
    hand_ausgeben
    puts
    puts 'Welchen Auftrag willst du wählen?'
    auftraege_sortiert = auftraege.sort_by(&:karte)
    auftraege_sortiert.reverse!
    auftraege_sortiert.each_with_index do |auftrag, index|
      puts "#{index + 1} = #{auftrag.karte}"
    end
    wahl = -1
    wahl = gets.to_i until wahl.positive? && (wahl <= auftraege.length)
    auftraege_sortiert[wahl - 1]
  end

  def waehle_karte(stich, waehlbare_karten)
    puts
    zeige_zustand
    puts
    puts 'Welche Karte willst du spielen?'
    if stich.length.positive?
      puts 'Bisher sieht der Stich so aus:'
      stich.karten.each do |karte|
        print "#{karte} "
      end
      puts
    end
    waehlbare_karten_sortiert = waehlbare_karten.sort
    waehlbare_karten_sortiert.reverse!
    waehlbare_karten_sortiert.each_with_index do |karte, index|
      puts "#{index + 1} = #{karte}"
    end
    wahl = -1
    wahl = gets.to_i until wahl.positive? && (wahl <= waehlbare_karten.length)
    waehlbare_karten_sortiert[wahl - 1]
  end

  def stich_fertig(stich)
    puts
    zeige_zustand
    puts
    puts 'Der Stich ist fertig. So sieht er jetzt aus:'
    stich.karten.each do |karte|
      print "#{karte} "
    end
    puts
  end
end
