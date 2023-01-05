require_relative 'spiel_information'
require_relative 'auftrag'
require_relative 'auftrag_verwalter'
require_relative 'richter'
require_relative 'karte'
require_relative 'karten_verwalter'
require_relative 'spieler'
require_relative 'spiel'

module SpielErsteller
  def self.erstelle_spiel(anzahl_spieler:, entscheider_klasse:, seed: Random.new_seed, anzahl_auftraege:, ausgeben:)
    zufalls_generator = Random.new(seed)
    spiel_information = SpielInformation.new(anzahl_spieler: anzahl_spieler)
    spieler = Array.new(ANZAHL_SPIELER) do |i|
      Spieler.new(entscheider: entscheider_klasse.new, spiel_informations_sicht: spiel_information.fuer_spieler(i))
    end
    karten_verwalter = KartenVerwalter.new(karten: Karte.alle, spiel_information: spiel_information)
    karten_verwalter.verteilen(zufalls_generator: zufalls_generator)
    auftrag_verwalter = AuftragVerwalter.new(auftraege: Auftrag.alle, spieler: spieler)
    auftrag_verwalter.auftraege_ziehen(anzahl: anzahl_auftraege, zufalls_generator: zufalls_generator)
    auftrag_verwalter.auftraege_verteilen(spiel_information: spiel_information)
    richter = Richter.new(spiel_information: spiel_information)
    spiel = Spiel.new(spieler: spieler, richter: richter, spiel_information: spiel_information, ausgeben: ausgeben)
  end
end
