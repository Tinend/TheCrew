# frozen_string_literal: true

require_relative 'reporter'

# Diese Klasse berichtet Sachen, die im Spiel passieren, via `puts`.
class PutsReporter < Reporter
  def berichte_start_situation(karten:, auftraege:)
    raise ArgumentError if karten.length != auftraege.length

    karten.each_index do |index|
      puts "Spieler #{index + 1}"
      puts "Hand: #{karten[index].sort.reverse.join(' ')}"
      puts "Aufträge: #{auftraege[index].sort.reverse.join(' ')}"
      puts
    end
  end

  def berichte_kommunikation(spieler_index:, kommunikation:)
    puts "Spieler #{spieler_index + 1} kommuniziert, dass #{kommunikation.karte} seine " \
         "#{kommunikation.art} #{kommunikation.karte.farbe.name}e ist."
  end

  def berichte_stich(stich:, vermasselte_auftraege:, erfuellte_auftraege:)
    puts "Spieler #{stich.sieger_index + 1} holt den Stich."
    puts stich.to_s
    unless vermasselte_auftraege.empty?
      vermasselt = vermasselte_auftraege.join(' ')
      puts "Folgender Auftrag wurde nicht erfüllt: #{vermasselt}" if vermasselte_auftraege.length == 1
      puts "Folgende Aufträge wurden nicht erfüllt: #{vermasselt}" if vermasselte_auftraege.length > 1
    end
    return if erfuellte_auftraege.empty?

    erfuellt = erfuellte_auftraege.join(' ')
    puts "Folgender Auftrag wurde erfüllt: #{erfuellt}" if erfuellte_auftraege.length == 1
    puts "Folgende Aufträge wurden erfüllt: #{erfuellt}" if erfuellte_auftraege.length > 1
  end

  def berichte_gewonnen
    puts 'Herzliche Gratulation!'
  end

  def berichte_verloren
    puts 'Leider wurde das Spiel verloren'
  end
end
