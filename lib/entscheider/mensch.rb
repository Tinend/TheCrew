# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'spiel_informations_sicht_benutzender'
require_relative 'zufalls_kommunizierender'

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
      if kommunikation.nil? or spieler_index == 0
        next
      end
      puts "Spieler #{spieler_index}:"
      if kommunikation.art == :hoechste
        puts " <= #{kommunikation.karte}"
      elsif kommunikation.art == :tiefste
        puts " >= #{kommunikation.karte}"
      else
        puts " = #{kommunikation.karte}"
      end
    end
  end

  def letzten_stich_ausgeben
    puts
    if !@spiel_informations_sicht.stiche.empty?
      puts "letzter Stich:"
      stich = @spiel_informations_sicht.stiche[-1]
      stich.karten.each do |karte|
        print "#{karte} "
      end
      puts
    end
  end

  def auftraege_ausgeben
    puts
    puts "Unerfuellte Auftraege:"
    @spiel_informations_sicht.unerfuellte_auftraege.each_with_index do |auftrag_array, spieler_index|
      next if auftrag_array.empty?
      if spieler_index == 0
        puts "Du:"
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
    puts "Deine Hand:"
    @spiel_informations_sicht.karten.sort.reverse.each do |karte|
      print "#{karte} "
    end
    puts
  end

  def waehle_kommunikation(kommunizierbares)
    puts
    zeige_zustand
    puts
    puts "Was willst du kommunizieren?"
    puts "0 = nicht kommunizieren"
    kommunizierbares_sortiert = kommunizierbares.sort_by {|kommunizierbares| kommunizierbares.karte}
    kommunizierbares_sortiert.reverse!
    kommunizierbares_sortiert.each_with_index do |kommunikation, index|
      art = if kommunikation.art == :hoechste
              "hoechste"
            elsif kommunikation.art == :tiefste
              "tiefste"
            else
              "einzige"
            end
      puts "#{index + 1} = Karte #{kommunikation.karte} als #{art}"
    end
    wahl = -1
    until 0 <= wahl and wahl <= kommunizierbares.length
      wahl = gets.to_i
    end
    kommunizierbares_sortiert[wahl - 1] if wahl != 0
  end

  def waehl_auftrag(auftraege)
    #puts
    #zeige_zustand
    puts
    hand_ausgeben
    puts
    puts "Welchen Auftrag willst du wählen?"
    auftraege_sortiert = auftraege.sort_by{|auftrag| auftrag.karte}
    auftraege_sortiert.reverse!
    auftraege_sortiert.each_with_index do |auftrag, index|
      puts "#{index + 1} = #{auftrag.karte.to_s}"
    end
    wahl = -1
    until 0 < wahl and wahl <= auftraege.length
      wahl = gets.to_i
    end
    auftraege_sortiert[wahl - 1]
  end

  def waehle_karte(stich, waehlbare_karten)
    puts
    zeige_zustand
    puts
    puts "Welche Karte willst du spielen?"
    if stich.length > 0
      puts "Bisher sieht der Stich so aus:"
      stich.karten.each do |karte|
        print karte.to_s + " "
      end
      puts
    end
    waehlbare_karten_sortiert = waehlbare_karten.sort
    waehlbare_karten_sortiert.reverse!
    waehlbare_karten_sortiert.each_with_index do |karte, index|
      puts "#{index + 1} = #{karte.to_s}"
    end
    wahl = -1
    until 0 < wahl and wahl <= waehlbare_karten.length
      wahl = gets.to_i
    end
    waehlbare_karten_sortiert[wahl - 1]
  end

  def stich_fertig(stich)
    puts
    zeige_zustand
    puts
    puts "Der Stich ist fertig. So sieht er jetzt aus:"
    stich.karten.each do |karte|
      print karte.to_s + " "
    end
    puts    
  end
end
