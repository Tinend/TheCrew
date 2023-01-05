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
  SEED = 42

  def initialize(basis_verzeichnis:)
    @basis_verzeichnis = basis_verzeichnis
  end

  def erstelle_bericht
    reporter = StrukturierterReporter.new
    TurnierOrganisator.organisiere_turnier(anzahl_spieler: ANZAHL_SPIELER, anzahl_spiele: ANZAHL_SPIELE, seed: SEED, entscheider_klassen: EntscheiderListe.entscheider_klassen, anzahl_auftraege: ANZAHL_AUFTRAEGE, reporter: reporter)
    { spiel_berichte_pro_entscheider: reporter.spiel_berichte_pro_entscheider, punkte_berichte: reporter.punkte_berichte }
  end

  def speichere_bericht(bericht)
    bericht[:spiel_berichte_pro_entscheider].each do |entscheider, entscheider_bericht|
      File.open(spiel_berichte_file_fuer_entscheider(entscheider), 'w') do |f|
        f.write(YAML::dump(entscheider_bericht))
      end
    end

    punkte_entwicklung = lade_punkte_entwicklung
    punkte_bericht = bericht[:punkte_berichte]
    return if punkte_entwicklung.last == punkte_bericht

    punkte_entwicklung.push(punkte_bericht) 
    File.open(punkte_entwicklung_file, 'w') { |f| f.write(YAML::dump(punkte_entwicklung)) }
  end

  def punkte_entwicklung_file
    File.join(@basis_verzeichnis, 'data', 'punkte_entwicklung.yml')
  end

  def spiel_berichte_file_fuer_entscheider(entscheider)
    File.join(@basis_verzeichnis, 'data', "spiel_berichte_#{entscheider}.yml")
  end

  def lade_spiel_berichte_fuer_entscheider(entscheider)
    file = spiel_berichte_file_fuer_entscheider(entscheider)
    if File.exists?(file)
      YAML::load(File.read(file))
    else
      []
    end
  end

  def lade_punkte_entwicklung
    if File.exists?(punkte_entwicklung_file)
      YAML::load(File.read(punkte_entwicklung_file))
    else
      []
    end
  end

  def lade_bericht
    spiel_berichte_pro_entscheider = EntscheiderListe.entscheider_klassen.map { |k| [k.to_s, lade_spiel_berichte_fuer_entscheider(k)] }.to_h
    {
      spiel_berichte_pro_entscheider: spiel_berichte_pro_entscheider,
      punkte_berichte: lade_punkte_entwicklung.last
    }
  end
end
