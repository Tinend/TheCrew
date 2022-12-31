# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'saeuger_auftrag_nehmer'

# Aufträge: Wenn er ihn hat, bevorzugt groß, wenn er ihn nicht hat, bevorzugt tief
# Grundlage für die meisten Entscheider mit Tiernamen
class Saeuger < Entscheider
  include SaeugerAuftragNehmer

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample
  end

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end

  def kommuniziert?
    rand(karten.length).zero?
  end

  def waehle_kommunikation(kommunizierbares)
    kommunizierbares.sample if kommuniziert?
  end
end
