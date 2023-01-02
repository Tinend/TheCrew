# coding: utf-8
# frozen_string_literal: true

# Simpler algorithmus zum Aufträge wählen
module SaeugerAuftragNehmer
  def waehl_auftrag(auftraege)
    auftraege.max_by { |auftrag| auftrag_punkte(auftrag) }
  end

  def auftrag_punkte(auftrag)
    if karten.include?(auftrag.karte)
      auftrag.karte.wert
    else
      max_karte = finde_max_karte(auftrag)
      if max_karte.nil?
        0
      else
        max_karte.wert - (auftrag.karte.wert * 0.1)
      end
    end
  end

  def karten
    @spiel_informations_sicht.karten
  end

  def finde_max_karte(auftrag)
    karten.select { |karte| !karte.trumpf? && karte.schlaegt?(auftrag.karte) }.max_by(&:wert)
  end
end
