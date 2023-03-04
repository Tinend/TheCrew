# frozen_string_literal: true

require_relative 'spiel_information'
require_relative 'auftrag'
require_relative 'auftrag_verwalter'
require_relative 'richter'
require_relative 'tee_reporter'
require_relative 'karte'
require_relative 'entscheider/mensch'
require_relative 'karten_verwalter'
require_relative 'spieler'
require_relative 'spiel'
require_relative 'reporter_mit_statistiker'

# Modul das alle Teile des Spieles erstellt, um dann schliesslich ein Spiel zu erstellen.
module SpielErsteller
  # rubocop:disable Metrics/ParameterLists
  def self.erstelle_spiel(
    anzahl_spieler:,
    entscheider_klasse:,
    zufalls_generator:,
    anzahl_auftraege:,
    reporter:,
    statistiker:
  )
    entscheider_klassen = Array.new(anzahl_spieler) { entscheider_klasse }
    erstelle_spiel_aus_entscheider_klassen(entscheider_klassen: entscheider_klassen,
                                           zufalls_generator: zufalls_generator,
                                           anzahl_auftraege: anzahl_auftraege,
                                           reporter: reporter, statistiker: statistiker)
  end

  def self.sub_zufalls_generator(zufalls_generator)
    Random.new(zufalls_generator.rand(1 << 64))
  end

  def self.erstelle_spiel_aus_entscheider_klassen(
    entscheider_klassen:,
    zufalls_generator:,
    anzahl_auftraege:,
    reporter:,
    statistiker:
  )
    statistiker.beachte_neues_spiel(entscheider_klassen.length)
    spiel_information = SpielInformation.new(anzahl_spieler: entscheider_klassen.length)
    spieler = erstelle_spieler(entscheider_klassen: entscheider_klassen, spiel_information: spiel_information,
                               zufalls_generator: zufalls_generator, statistiker: statistiker)
    spieler_reporter = spieler.map(&:entscheider).map(&:reporter).compact
    bereite_spiel_vor(spiel_information: spiel_information, zufalls_generator: zufalls_generator, spieler: spieler,
                      anzahl_auftraege: anzahl_auftraege)
    richter = Richter.new(spiel_information: spiel_information)
    tee_reporter = TeeReporter.new(spieler_reporter + [reporter])
    reporter_mit_statistiker = ReporterMitStatistiker.new(tee_reporter, statistiker)
    Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information,
              reporter: reporter_mit_statistiker)
  end

  def self.erstelle_spieler(entscheider_klassen:, spiel_information:, zufalls_generator:, statistiker:)
    entscheider_klassen.map.with_index do |e, i|
      entscheider = e.new(zufalls_generator: sub_zufalls_generator(zufalls_generator),
                          zaehler_manager: statistiker.neuer_zaehler_manager)
      Spieler.new(entscheider: entscheider, spiel_informations_sicht: spiel_information.fuer_spieler(i))
    end
  end

  def self.bereite_spiel_vor(spiel_information:, zufalls_generator:, spieler:, anzahl_auftraege:)
    karten_verwalter = KartenVerwalter.new(karten: Karte.alle.dup, spiel_information: spiel_information)
    karten_verwalter.verteilen(zufalls_generator: zufalls_generator)
    auftrag_verwalter = AuftragVerwalter.new(auftraege: Auftrag.alle.dup, spieler: spieler)
    auftrag_verwalter.auftraege_ziehen(anzahl: anzahl_auftraege, zufalls_generator: zufalls_generator)
    auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
  end

  def self.erstelle_menschen_spiel(
    anzahl_spieler:,
    entscheider_klasse:,
    zufalls_generator:,
    anzahl_auftraege:,
    reporter:,
    statistiker:
  )
    entscheider_klassen = Array.new(anzahl_spieler) do |i|
      i.zero? ? Mensch : entscheider_klasse
    end
    erstelle_spiel_aus_entscheider_klassen(entscheider_klassen: entscheider_klassen,
                                           zufalls_generator: zufalls_generator,
                                           anzahl_auftraege: anzahl_auftraege,
                                           reporter: reporter, statistiker: statistiker)
  end
  # rubocop:enable Metrics/ParameterLists
end
