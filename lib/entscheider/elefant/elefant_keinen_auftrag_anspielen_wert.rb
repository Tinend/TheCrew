# coding: utf-8
# frozen_string_literal: true

# berechnet Wert für Karten anspielen, wenn
# Karte kein Auftrag ist
require_relative 'elefant_trumpf_anspielen_wert'
require_relative 'elefant_multiple_auftrag_farbe_anspielen_wert'

# Berechnet, wie gut eine Karte zum Anspielen ist, wenn sie kein Auftrag ist
module ElefantKeinenAuftragAnspielenWert
  include ElefantTrumpfAnspielenWert
  include ElefantMultipleAuftragFarbeAnspielenWert

  def keinen_auftrag_anspielen_wert(karte:, elefant_rueckgabe:)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(karte.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe.positive? && fremde_auftraege_mit_farbe.positive?
      multiple_auftrag_farbe_anspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe,
                                            elefant_rueckgabe: elefant_rueckgabe)
    elsif eigene_auftraege_mit_farbe.positive?
      eigene_auftrag_farbe_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    elsif fremde_auftraege_mit_farbe.positive?
      fremden_auftrag_farbe_anspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe,
                                           elefant_rueckgabe: elefant_rueckgabe)
    else
      keine_auftrag_farbe_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigene_auftrag_farbe_anspielen_wert(karte:, elefant_rueckgabe:)
    auftrag = tiefster_eigener_auftrag_auf_fremder_hand_mit_farbe(karte.farbe)
    if auftrag.nil?
      eigene_auftrag_farbe_blank_machen_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    else
      eigene_auftrag_farbe_nicht_blank_machen_anspielen_wert(karte: karte, auftrag: auftrag,
                                                             elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigene_auftrag_farbe_blank_machen_anspielen_wert(karte:, elefant_rueckgabe:)
    if jeder_kann_unterbieten?(karte: karte)
      elefant_rueckgabe.symbol = :eigene_farbe_blank_machen_hoch_anspielen
      elefant_rueckgabe.wert = [0, 0, 2, karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :eigene_farbe_blank_machen_tief_anspielen
      elefant_rueckgabe.wert = [0, 0, 1, karte.wert, 0]
    end
  end

  def eigene_auftrag_farbe_nicht_blank_machen_anspielen_wert(karte:, auftrag:, elefant_rueckgabe:)
    if jeder_kann_unterbieten?(karte: karte)
      eigene_auftrag_farbe_holen_anspielen_wert(karte: karte, auftrag: auftrag, elefant_rueckgabe: elefant_rueckgabe)
    elsif kurze_farbe?(farbe: karte.farbe) &&
          @spiel_informations_sicht.karten_mit_farbe(karte.farbe).length == 1 &&
          @spiel_informations_sicht.karten_mit_farbe(Farbe::RAKETE).length >= 1
      elefant_rueckgabe.symbol = :eigene_farbe_nicht_blank_machen_kurze_farbe_anspielen
      elefant_rueckgabe.wert = [0, 0, 0, 1, 0]
    else
      elefant_rueckgabe.symbol = :eigene_farbe_nicht_blank_machen_lange_farbe_anspielen
      elefant_rueckgabe.wert = [0, 0, -1, -karte.wert, 0]
    end
  end

  def eigene_auftrag_farbe_holen_anspielen_wert(karte:, auftrag:, elefant_rueckgabe:)
    if karte.wert > auftrag.karte.wert
      elefant_rueckgabe.symbol = :eigene_auftrag_farbe_holen_anspielen
      elefant_rueckgabe.wert = [0, 1, 3, karte.wert, 0]
    elsif habe_hohe_karte_mit_farbe?(farbe: karte.farbe, wert: auftrag.karte.wert) ||
          kurze_farbe?(farbe: karte.farbe)
      elefant_rueckgabe.symbol = :eigene_auftrag_farbe_vielleicht_holen
      elefant_rueckgabe.wert = [0, 0, 1, 0, 0]
    else
      elefant_rueckgabe.symbol = :eigene_auftrag_farbe_nicht_holen
      elefant_rueckgabe.wert = [0, 0, -1, 0, 0]
    end
  end

  def fremden_auftrag_farbe_anspielen_wert(karte:, auftraege_mit_farbe:, elefant_rueckgabe:)
    if (1..@spiel_informations_sicht.anzahl_spieler - 1).any? do |spieler_index|
         (auftraege_mit_farbe[spieler_index]).positive? &&
         kann_ueberbieten?(karte: karte, spieler_index: spieler_index)
       end
      elefant_rueckgabe.symbol = :fremde_auftrag_farbe_sicher_anspielen
      elefant_rueckgabe.wert = [0, 1, 0, 0, -karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :fremde_auftrag_farbe_unsicher_anspielen
      elefant_rueckgabe.wert = [0, -1, 0, 0, -karte.wert, 0]
    end
  end

  def keine_auftrag_farbe_anspielen_wert(karte:, elefant_rueckgabe:)
    if karte.trumpf?
      trumpf_anspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    elsif habe_noch_auftraege?
      eigene_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte: karte,
                                                                      elefant_rueckgabe: elefant_rueckgabe)
    else
      fremde_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte: karte,
                                                                      elefant_rueckgabe: elefant_rueckgabe)
    end
  end

  def eigene_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte:, elefant_rueckgabe:)
    farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    if jeder_kann_unterbieten?(karte: karte)
      elefant_rueckgabe.symbol = :eigene_auftraege_mit_anderer_farbe_unterstuetzen_hoch_anspielen
      elefant_rueckgabe.wert = [0, 0, farb_laenge - 1, karte.wert, 0]
    else
      elefant_rueckgabe.symbol = :eigene_auftraege_mit_anderer_farbe_unterstuetzen_tief_anspielen
      elefant_rueckgabe.wert = [0, 0, (farb_laenge * 0.1) - 0.1, karte.wert, 0]
    end
  end

  def fremde_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte:, elefant_rueckgabe:)
    farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    elefant_rueckgabe.symbol = :fremde_auftraege_mit_anderer_farbe_unterstuetzen_anspielen
    elefant_rueckgabe.wert = [0, 0, 12 - karte.wert - (farb_laenge * 2), 0, 0]
  end
end
