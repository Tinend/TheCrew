# coding: utf-8
# frozen_string_literal: true

# berechnet Wert für Karten anspielen, wenn
# Karte ein fremder Auftrag ist
module ElefantFremdenAuftragAbspielenWert
  def fremden_auftrag_abspielen_wert(karte:, stich:, ziel_spieler_index:, elefant_rueckgabe:)
    if hat_gespielt?(spieler_index: ziel_spieler_index, stich: stich)
      vielleicht_auftrag_reinwerfen_abspielen_wert(karte: karte, stich: stich, ziel_spieler_index: ziel_spieler_index,
                                                   elefant_rueckgabe: elefant_rueckgabe)
    else
      holbaren_fremden_auftrag_abspielen_wert(karte: karte, stich: stich, ziel_spieler_index: ziel_spieler_index,
                                              elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def holbaren_fremden_auftrag_abspielen_wert(karte:, stich:, ziel_spieler_index:, elefant_rueckgabe:)
    max_karte = stich.staerkste_karte
    max_karte = karte if karte.schlaegt?(stich.staerkste_karte)
    elefant_rueckgabe.symbol = :fremden_auftrag_holbar_abspielen
    if kann_schlagen?(karte: max_karte, spieler_index: ziel_spieler_index) &&
       !max_karte.trumpf?
      elefant_rueckgabe.wert = [0, 1, 0, 0, 10]
    elsif max_karte.trumpf? && kann_schlagen?(karte: max_karte, spieler_index: ziel_spieler_index)
      elefant_rueckgabe.wert = [0, 1, 2 - stich.staerkste_karte.wert, 0, 10]
    else
      elefant_rueckgabe.wert = [0, -1, 0, 0, 10]
    end
  end

  def vielleicht_auftrag_reinwerfen_abspielen_wert(karte:, stich:, ziel_spieler_index:, elefant_rueckgabe:)
    if stich.sieger_index == ziel_spieler_index
      auftrag_reinwerfen_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    else
      elefant_rueckgabe.symbol = :fremden_auftrag_vermasseln_abspielen
      elefant_rueckgabe.wert = [0, -1, 0, 0, 0]
    end
  end

  def auftrag_reinwerfen_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    if !karte.schlaegt?(stich.staerkste_karte) &&
       jeder_kann_unterbieten?(karte: stich.staerkste_karte,
                               end_index: @spiel_informations_sicht.anzahl_spieler - 1 - stich.length)
      elefant_rueckgabe.symbol = :fremden_auftrag_sicher_abspielen
      elefant_rueckgabe.wert = [0, 1, 0, 0, 10]
    else
      elefant_rueckgabe.symbol = :fremden_auftrag_unsicher_abspielen
      elefant_rueckgabe.wert = [0, -1, 0, 0, 0]
    end
  end
end
