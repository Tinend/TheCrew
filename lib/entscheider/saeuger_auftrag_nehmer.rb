# coding: utf-8
# frozen_string_literal: true

# Simpler algorithmus zum Aufträge wählen
module SaeugerAuftragNehmer
  def waehl_auftrag(auftraege)
    auftraege.max_by { |auftrag| auftrag_punkte(auftrag: auftrag)}
  end

  def auftrag_punkte(auftrag:)
    if hand.include?(auftrag.karte)
      auftrag.karte.wert
    else
      auftrag_nicht_auf_hand_punke(auftrag: auftrag)
    end
  end

  def auftrag_nicht_auf_hand_punke(auftrag:)
    max_karte = finde_max_karte(auftrag: auftrag)
    if blank_fuer_auftrag?(auftrag: auftrag) && habe_trumpf?
      7 - (auftrag.karte.wert * 0.1)
    elsif max_karte.nil?
      3 - (auftrag.karte.wert * 0.1)
    else
      max_karte.wert - (auftrag.karte.wert * 0.1)
    end
  end

  def finde_max_karte(auftrag:)
    hand.select do |karte|
      @spiel_informations_sicht.alle_auftraege.all? { |auftrag2| auftrag2.karte != karte } &&
        !karte.trumpf? && karte.schlaegt?(auftrag.karte)
    end.max_by(&:wert)
  end

  def blank_fuer_auftrag?(auftrag:)
    hand.all? { |karte| karte.farbe != auftrag.farbe }
  end

  def habe_trumpf?
    hand.any?(&:trumpf?)
  end

  def hand
    @spiel_informations_sicht.karten
  end
end
