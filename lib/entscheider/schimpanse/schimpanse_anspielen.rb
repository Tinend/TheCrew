# coding: utf-8
# frozen_string_literal: true

require_relative 'schimpansen_lege_wert'

# Module für das Anspielen vom Rhinoceros
module SchimpanseAnspielen

  EIGENE_AUFTRAEGE_HOLEN_WERT_BASIS = 0.5
  
  def anspielen(waehlbare_karten)
    #puts
    #puts zeitdruck
    #puts zeitdruck_mit_schwelle
    waehlbare_karten.max_by { |karte| anspiel_wert_karte(karte) }
  end

  def anspiel_wert_karte(karte)
    #puts karte
    schimpansen_lege_wert = SchimpansenLegeWert.new
    #p [10, schimpansen_lege_wert]
    eigenen_auftrag_holen_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    #p [20, schimpansen_lege_wert]
    anderen_auftrag_geben_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    #p [30, schimpansen_lege_wert]
    selber_blank_machen_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    #p [40, schimpansen_lege_wert]
    andere_blank_machen_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    #p [50, schimpansen_lege_wert]
    schimpansen_lege_wert
  end

  def eigenen_auftrag_holen_anspielen(schimpansen_lege_wert:, karte:)
    relevante_auftrag_zahl = eigene_unerfuellte_auftraege.count {|auftrag|
      auftrag.farbe == karte.farbe &&
        auftrag.karte.wert < karte.wert &&
        karten.all? {|eigene_karte| eigene_karte != auftrag.karte}
    }
    wert = (1 - EIGENE_AUFTRAEGE_HOLEN_WERT_BASIS ** relevante_auftrag_zahl) * 2
    toedlich = eigene_unerfuellte_auftraege.any? {|auftrag| auftrag.karte == karte}
    if auftrag_zu_tief_zum_anspielen?(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte, toedlich: toedlich)
      wert += 1 if toedlich
      schimpansen_lege_wert.warnen(-wert)
      schimpansen_lege_wert.gefaehrden(-wert * zeitdruck_mit_schwelle)
      schimpansen_lege_wert.nerven(-karte.wert * wert)
    elsif toedlich
      schimpansen_lege_wert.toeten
    elsif wert > 0
      schimpansen_lege_wert.benachteiligen(karte.wert * wert)
    end
  end
  
  def auftrag_zu_tief_zum_anspielen?(schimpansen_lege_wert:, karte:, toedlich:)
    return false if (2 - zeitdruck) * 7 > karte.wert * 2
    (1..@spiel_informations_sicht.anzahl_spieler - 1).each {|index|
      moegliche_karten = moegliche_karten_von_spieler_mit_farbe(spieler_index: index, farbe: karte.farbe)
      min_karte = moegliche_karten.min
      return false if !min_karte.nil? && min_karte.wert > karte.wert
    }
    true
  end
  
  def anderen_auftrag_geben_anspielen(schimpansen_lege_wert:, karte:)
    #puts 1
    if @spiel_informations_sicht.unerfuellte_auftraege[1..].flatten.any? {|auftrag| auftrag.karte == karte}
      anderen_auftrags_karte_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    elsif andere_farbe_anspielen_tief_genug?(karte: karte)
      anderen_auftrag_farbe_anspielen(schimpansen_lege_wert: schimpansen_lege_wert, karte: karte)
    end
  end

  def andere_farbe_anspielen_tief_genug?(karte:)
    (2 - zeitdruck) * 7 > karte.wert
  end

  def anderen_auftrags_karte_anspielen(schimpansen_lege_wert:, karte:)
    #puts 2
    @spiel_informations_sicht.unerfuellte_auftraege[1..].each_with_index do |auftrag_liste, spieler_index|
      moegliche_karten = moegliche_karten_von_spieler_mit_farbe(spieler_index: spieler_index + 1, farbe: karte.farbe)
      max_karten_wert = 0
      max_karten_wert = moegliche_karten.max.wert if !moegliche_karten.empty?
      auftrag_liste.each do |auftrag|
        if auftrag.karte == karte && max_karten_wert < karte.wert && !trumpf_stech_annahme_zeitdruck?
          schimpansen_lege_wert.toeten
        elsif auftrag.karte == karte
          schimpansen_lege_wert.nerven(-2)
          schimpansen_lege_wert.gefaehrden(-0.2 * zeitdruck_mit_schwelle)
          schimpansen_lege_wert.benachteiligen(karte.wert)
        end
      end
    end
  end

  def anderen_auftrag_farbe_anspielen(schimpansen_lege_wert:, karte:)
    #puts 3
    @spiel_informations_sicht.unerfuellte_auftraege[1..].each_with_index do |auftrag_liste, spieler_index|
      moegliche_karten = moegliche_karten_von_spieler_mit_farbe(spieler_index: spieler_index + 1, farbe: karte.farbe)
      max_karten_wert = 0
      max_karten_wert = moegliche_karten.max.wert if !moegliche_karten.empty?
      #puts moegliche_karten.max
      auftrag_liste.each do |auftrag|
        if auftrag.farbe == karte.farbe && max_karten_wert > karte.wert || trumpf_stech_annahme_zeitdruck?
          schimpansen_lege_wert.nerven(-1)
          schimpansen_lege_wert.gefaehrden(-0.1 * zeitdruck_mit_schwelle)
        end
      end
    end
  end
  
  def selber_blank_machen_anspielen(schimpansen_lege_wert:, karte:)
  end

  def andere_blank_machen_anspielen(schimpansen_lege_wert:, karte:)
  end

end
