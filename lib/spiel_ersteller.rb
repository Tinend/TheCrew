# frozen_string_literal: true

require_relative 'spiel_information'
require_relative 'auftrag'
require_relative 'auftrag_verwalter'
require_relative 'richter'
require_relative 'karte'
require_relative 'karten_verwalter'
require_relative 'spieler'
require_relative 'spiel'

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
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spieler = Array.new(anzahl_spieler) do |i|
      entscheider = entscheider_klasse.new(zufalls_generator: Random.new(zufalls_generator.rand(1 << 64)),
                                           zaehler_manager: statistiker.neuer_zaehler_manager)
      Spieler.new(entscheider: entscheider, spiel_informations_sicht: spiel_information.fuer_spieler(i))
    end
    karten_verwalter = KartenVerwalter.new(karten: Karte.alle, spiel_information: spiel_information)
    karten_verwalter.verteilen(zufalls_generator: zufalls_generator)
    auftrag_verwalter = AuftragVerwalter.new(auftraege: Auftrag.alle, spieler: spieler)
    auftrag_verwalter.auftraege_ziehen(anzahl: anzahl_auftraege, zufalls_generator: zufalls_generator)
    auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
    richter = Richter.new(spiel_information: spiel_information)
    Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information, reporter: reporter,
              statistiker: statistiker)
  end

  def self.erstelle_menschen_spiel(
    anzahl_spieler:,
    entscheider_klasse:,
    zufalls_generator:,
    anzahl_auftraege:,
    reporter:,
    statistiker:
  )
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spieler = Array.new(anzahl_spieler) do |i|
      entscheider = if i.zero?
                      Mensch.new(zufalls_generator: Random.new(zufalls_generator.rand(1 << 64)),
                                 zaehler_manager: statistiker.neuer_zaehler_manager)
                    else
                      entscheider_klasse.new(zufalls_generator: Random.new(zufalls_generator.rand(1 << 64)),
                                             zaehler_manager: statistiker.neuer_zaehler_manager)
                    end
      Spieler.new(entscheider: entscheider, spiel_informations_sicht: spiel_information.fuer_spieler(i))
    end
    karten_verwalter = KartenVerwalter.new(karten: Karte.alle, spiel_information: spiel_information)
    karten_verwalter.verteilen(zufalls_generator: zufalls_generator)
    auftrag_verwalter = AuftragVerwalter.new(auftraege: Auftrag.alle, spieler: spieler)
    auftrag_verwalter.auftraege_ziehen(anzahl: anzahl_auftraege, zufalls_generator: zufalls_generator)
    auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
    richter = Richter.new(spiel_information: spiel_information)
    Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information, reporter: reporter,
              statistiker: statistiker)
  end
  # rubocop:enable Metrics/ParameterLists
end
