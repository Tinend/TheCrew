# coding: utf-8
# frozen_string_literal: true

def turnier_hilfe
  puts 'Benutzung: /usr/bin/bundle exec ruby bin/turnier.rb [Argumente]'
  puts '   -a=x         Setzt die Zahl der Aufträge auf x, Standart ist 6'
  puts '   -b           Schaltet Berichte/Statistiken zu den Bots aus'
  puts '   -h           Gibt diese Hilfe aus'
  puts '   -u           Wiederholt das Turnier unendlich oft'
  puts '   -r=x         Setzt den Seed auf x. Wenn x=0, wird stattdessen ein zufälliger genommen'
  puts "   -s=x         Setzt die Zahl der Spiele auf x fest, Standart is 10'000"
  puts '   -x=x1,x2,... Lässt die Spieler x1, x2... an einem Turnier teilnehmen'
  puts '                standartmäßig sind alle ausgewählt'
  puts '   -y=x1,x2,... Schließt die Spieler x1, x2... aus dem Turnier aus'
  exit
end
