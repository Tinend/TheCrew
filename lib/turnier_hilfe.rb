# coding: utf-8
# frozen_string_literal: true

def turnier_hilfe
  puts 'Benutzung: /usr/bin/bundle exec ruby bin/tournier.rb [Argumente]'
  puts '   -a=x         Setzt die Zahl der Aufträge auf x, Standart ist 6'
  puts '   -h           Gibt diese Hilfe aus'
  puts '   -r=x         Setzt den Seed auf x. Wenn x=0, wird stattdessen ein zufälliger genommen'
  puts "   -s=x         Setzt die Zahl der Spiele auf x fest, Standart is 10'000"
  puts '   -x=[spieler] Schließt einen Spieler aus dem Tournier aus'
  exit
end
