# frozen_string_literal: true

require_relative 'reporter'
require 'yaml'

# Dieser Reporter erstellt ein Hash mit Spiel Informationen.
class StrukturierterReporter < Reporter
  def initialize
    super()
    @spiel_berichte = []
    @spiel_berichte_pro_entscheider = {}
    @punkte_berichte = []
  end

  attr_reader :spiel_berichte_pro_entscheider, :punkte_berichte

  def karte_string(karte)
    "#{karte.farbe.name} #{karte.wert}"
  end

  def karten_string(karten)
    karten.map { |k| karte_string(k) }.join(', ')
  end

  def auftraege_string(auftraege)
    auftraege.map { |a| karte_string(a.karte) }.join(', ')
  end

  def berichte_start_situation(karten:, auftraege:)
    @spiel_berichte.push(
      {
        'karten' => karten.map { |k| karten_string(k) },
        'auftraege' => auftraege.map { |a| auftraege_string(a) },
        'kommunikationen' => [],
        'stiche' => []
      }
    )
  end

  def berichte_kommunikation(spieler_index:, kommunikation:)
    @spiel_berichte.last['kommunikationen'].push(
      {
        'spieler_index' => spieler_index,
        'karte' => karte_string(kommunikation.karte),
        'art' => kommunikation.art.to_s
      }
    )
  end

  def berichte_stich(stich:, vermasselte_auftraege:, erfuellte_auftraege:)
    stich_hash = {
      'anspieler' => stich.gespielte_karten[0].spieler_index,
      'karten' => karten_string(stich.karten)
    }
    stich_hash['vermasselte_auftraege'] = auftraege_string(vermasselte_auftraege) unless vermasselte_auftraege.empty?
    stich_hash['erfuellte_auftraege'] = auftraege_string(erfuellte_auftraege) unless erfuellte_auftraege.empty?
    @spiel_berichte.last['stiche'].push(stich_hash)
  end

  def berichte_gewonnen
    @spiel_berichte.last['resultat'] = 'gewonnen'
  end

  def berichte_verloren
    @spiel_berichte.last['resultat'] = 'verloren'
  end

  def berichte_spiel_statistiken(statistiken); end

  def berichte_gesamt_statistiken(gesamt_statistiken:, gewonnen_statistiken:, verloren_statistiken:); end

  def berichte_punkte(entscheider:, punkte:)
    @spiel_berichte_pro_entscheider[entscheider.to_s] = @spiel_berichte
    @spiel_berichte = []
    @punkte_berichte.push(
      {
        'entscheider' => entscheider.to_s,
        'punkte' => punkte
      }
    )
  end
end
