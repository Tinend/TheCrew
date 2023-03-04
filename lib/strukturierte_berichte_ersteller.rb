# frozen_string_literal: true

require_relative 'turnier_organisator'
require_relative 'strukturierter_reporter'
require_relative 'entscheider_liste'
require 'yaml'

# Lässt ein Turnier mit fixen Einstellungen laufen und erstellt einen strukturierten Bericht zum Turnier.
# Diesen kann er laden und speichern.
class StrukturierteBerichteErsteller
  ANZAHL_SPIELER = 4
  ANZAHL_SPIELE = 100
  ANZAHL_AUFTRAEGE = 6
  TURNIER_EINSTELLUNGEN = TurnierOrganisator::TurnierEinstellungen.new(anzahl_spieler: ANZAHL_SPIELER,
                                                                       anzahl_spiele: ANZAHL_SPIELE,
                                                                       anzahl_auftraege: ANZAHL_AUFTRAEGE)
  SEED = 42

  def initialize(basis_verzeichnis:, entscheider_klasse:)
    @basis_verzeichnis = basis_verzeichnis
    @entscheider_klasse = entscheider_klasse
  end

  def erstelle_bericht
    reporter = StrukturierterReporter.new
    TurnierOrganisator.organisiere_turnier(turnier_einstellungen: TURNIER_EINSTELLUNGEN, seed: SEED,
                                           entscheider_klassen: [@entscheider_klasse],
                                           reporter: reporter)
    {
      spiel_berichte: reporter.spiel_berichte,
      punkte: reporter.punkte
    }
  end

  def finde_entscheider_punkte_bericht(punkte_berichte)
    punkte_berichte.find { |e| e['entscheider'] == @entscheider_klasse.to_s }
  end

  def speichere_bericht(bericht)
    File.write(spiel_berichte_file, YAML.dump(bericht[:spiel_berichte]))

    punkte_entwicklung = lade_punkte_entwicklung
    punkte = bericht[:punkte]
    entscheider_punkte_bericht = finde_entscheider_punkte_bericht(punkte_entwicklung.last)
    return if entscheider_punkte_bericht && entscheider_punkte_bericht['punkte'] == punkte

    punkte_berichte = punkte_entwicklung.last.map(&:dup)
    entscheider_punkte_bericht = finde_entscheider_punkte_bericht(punkte_berichte)
    if entscheider_punkte_bericht
      entscheider_punkte_bericht['punkte'] = punkte
    else
      punkte_berichte.push({ 'entscheider' => @entscheider_klasse.to_s, 'punkte' => punkte })
    end
    punkte_entwicklung.push(punkte_berichte)
    File.write(punkte_entwicklung_file, YAML.dump(punkte_entwicklung))
  end

  def punkte_entwicklung_file
    File.join(@basis_verzeichnis, 'data', 'punkte_entwicklung.yml')
  end

  def spiel_berichte_file
    File.join(@basis_verzeichnis, 'data', "spiel_berichte_#{@entscheider_klasse}.yml")
  end

  def lade_punkte_entwicklung
    if File.exist?(punkte_entwicklung_file)
      YAML.safe_load(File.read(punkte_entwicklung_file))
    else
      []
    end
  end

  def lade_spiel_berichte
    file = spiel_berichte_file
    if File.exist?(file)
      YAML.safe_load(File.read(file))
    else
      []
    end
  end

  def lade_bericht
    punkte_entwicklung = lade_punkte_entwicklung
    entscheider_punkte_bericht = finde_entscheider_punkte_bericht(punkte_entwicklung.last)
    punkte = entscheider_punkte_bericht ? entscheider_punkte_bericht['punkte'] : nil
    {
      spiel_berichte: lade_spiel_berichte,
      punkte: punkte
    }
  end
end
