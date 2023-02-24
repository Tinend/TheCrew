# coding: utf-8
# frozen_string_literal: true

require_relative 'puts_reporter'

# Dieser Reporter macht nichts ausser die Anzahl Punkte berichten.
class MenschSpielReporter < PutsReporter
  include StatistikenPutser

  def berichte_start_situation(karten:, auftraege:)
    raise ArgumentError if karten.length != auftraege.length

    karten.each_index do |index|
      if index == 0
        puts "Du:"
      else
        puts "Spieler #{index + 1}"
      end
      puts "Aufträge: #{auftraege[index].sort.reverse.join(' ')}"
      puts
    end
  end

  def berichte_kommunikation(spieler_index:, kommunikation:)
    super(spieler_index: spieler_index, kommunikation: kommunikation) if !spieler_index.zero?
  end

end
