# coding: utf-8
# frozen_string_literal: true

require_relative 'elefant_nuetzliches'
require_relative 'elefant_keinen_auftrag_anspielen_wert'
require_relative 'elefant_rueckgabe'

# Module für das Anspielen vom Elefant
module ElefantAnspielen
  include ElefantNuetzliches
  include ElefantKeinenAuftragAnspielenWert

  def anspielen(waehlbare_karten)
    #puts
    waehlbare_rueckgaben = waehlbare_karten.collect {|karte|
      elefant_rueckgabe = ElefantRueckgabe.new(karte)
      anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
      #puts elefant_rueckgabe.karte
      #puts elefant_rueckgabe.symbol
      #p elefant_rueckgabe.wert
      elefant_rueckgabe
    }
    #waehlbare_karten.max_by { |karte| anspielen_wert(karte) }
    rueckgabe = waehlbare_rueckgaben.max
    @zaehler_manager.erhoehe_zaehler(rueckgabe.symbol)
    #puts rueckgabe.karte
    #puts rueckgabe.symbol
    #p rueckgabe.wert
    rueckgabe.karte
  end

  # wie gut eine Karte zum Anspielen geeignet ist
  def anspielen_wert(karte:, elefant_rueckgabe:)
    karten_auftrag_index = karte_ist_auftrag_von(karte)
    if karten_auftrag_index.nil?
      keinen_auftrag_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    elsif karten_auftrag_index.zero?
      eigenen_auftrag_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    else
      fremden_auftrag_anspielen_wert(karte: karte, auftrag_index: karten_auftrag_index,
                                     elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigenen_auftrag_anspielen_wert(karte:, elefant_rueckgabe:)
    if jeder_kann_unterbieten?(karte: karte)
      holbaren_eigenen_auftrag_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    else
      elefant_rueckgabe.symbol = :eigenen_auftrag_sicher_unanspielen
      elefant_rueckgabe.wert = [0, -1, 0, 0, 0]
    end
  end

  def holbaren_eigenen_auftrag_anspielen_wert(karte:, elefant_rueckgabe:)
    if nur_blanke_auftraege_von?(auftrag_index: 0, farbe: karte.farbe)
      elefant_rueckgabe.symbol = :holbaren_eigenen_auftrag_anspielen
      elefant_rueckgabe.wert = [0, 1, 4, karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :holbaren_eigenen_doppel_blanken_auftrag_anspielen
      elefant_rueckgabe.wert = [-1, 0, 0, 0, 0]
    end
  end

  def fremden_auftrag_anspielen_wert(karte:, auftrag_index:, elefant_rueckgabe:)
    if ist_blank_auf_farbe?(farbe: karte.farbe, spieler_index: auftrag_index) ||
       kann_ueberbieten?(karte: karte, spieler_index: auftrag_index)
      holbaren_fremden_auftrag_anspielen_wert(karte: karte, auftrag_index: auftrag_index,
                                              elefant_rueckgabe: elefant_rueckgabe)
    else
      elefant_rueckgabe.symbol = :fremden_auftrag_unsicher_anspielen
      elefant_rueckgabe.wert = [0, -1, -1, 0, 0]
    end
  end

  def holbaren_fremden_auftrag_anspielen_wert(karte:, auftrag_index:, elefant_rueckgabe:)
    if nur_blanke_auftraege_von?(auftrag_index: auftrag_index, farbe: karte.farbe)
      elefant_rueckgabe.symbol = :holbaren_fremden_auftrag_anspielen_anspielen
      elefant_rueckgabe.wert = [0, 1, 1, 0, 0]
    else
      elefant_rueckgabe.symbol = :holbaren_fremden_doppel_blanken_auftrag_anspielen
      elefant_rueckgabe.wert = [-1, 0, 0, 0, 0]
    end
  end

  def nur_blanke_auftraege_von?(auftrag_index:, farbe:)
    auftraege = @spiel_informations_sicht.unerfuellte_auftraege_mit_farbe(farbe).dup
    auftraege.delete_at(auftrag_index)
    negativ_karten = auftraege.flatten.collect do |auftrag|
      auftrag.karte
    end
    karten = Karte::alle_mit_farbe(farbe) - negativ_karten
    (0..@spiel_informations_sicht.anzahl_spieler - 1).each do |spieler_index|
      return false if (karten & @spiel_informations_sicht.moegliche_karten(spieler_index)).empty? &&
                      !(@spiel_informations_sicht.moegliche_karten(spieler_index) & Karte::alle_mit_farbe(farbe)).empty?
    end
    true
  end

  
  def ist_blank_auf_farbe?(farbe:, spieler_index:)
    @spiel_informations_sicht.moegliche_karten(spieler_index).all? do |moegliche_karte|
      moegliche_karte.farbe != farbe
    end
  end
end
