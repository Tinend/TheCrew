# coding: utf-8
# frozen_string_literal: true

def ein_spiel_hilfe
  puts 'Benutzung: /usr/bin/bundle exec ruby bin/ein_spiel.rb [Argumente]'
  puts '   -a=x         Setzt die Zahl der Aufträge auf x, Standart ist 1'
  puts '   -b           Schaltet Berichte/Statistiken zu den Bots aus'
  puts '   -h           Gibt diese Hilfe aus'
  puts '   -r=x         Setzt den Seed auf x. Standartmäßig oder bei x=0, wird ein Zufälliger genommen'
  puts '   -s=x         Setzt die Zahl der Spieler auf x, Standart is 4'
  puts '   -x=[spieler] Nimmt diesen Spieler für das Spiel. Standard ist der ZufallsEntscheider'
  exit
end
