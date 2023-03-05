# coding: utf-8
# frozen_string_literal: true

require_relative '../entscheider'
require_relative 'gemeinsam/saeuger_auftrag_nehmer'
require_relative 'gemeinsam/spiel_informations_sicht_benutzender'

# Aufträge: Wenn er ihn hat, bevorzugt groß, wenn er ihn nicht hat, bevorzugt tief
# Grundlage für die meisten Entscheider mit Tiernamen
class GeschlosseneFormelBot < Entscheider
  include SaeugerAuftragNehmer
  include SpielInformationsSichtBenutzender

  def waehle_karte(stich, waehlbare_karten)
    waehlbare_karten.max_by { |karte| geschlossene_formel_wert(karte, stich) }
  end

  def karten_wert(karte)
    return 10 + karte.wert if karte.trumpf?

    karte.wert
  end

  def geschlossene_formel_wert(karte, _stich)
    karten_wert(karte) * ((@spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(karte.farbe)[0].length * 2) - 1)
  end
end
