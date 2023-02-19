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

  def keinen_auftrag_anspielen_wert(karte)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(karte.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe.positive? && fremde_auftraege_mit_farbe.positive?
      eigen_und_fremd_auftrag_farbe_anspielen_wert(karte: karte)
    elsif eigene_auftraege_mit_farbe.positive?
      eigene_auftrag_farbe_anspielen_wert(karte: karte)
    elsif fremde_auftraege_mit_farbe.positive?
      fremden_auftrag_farbe_anspielen_wert(karte: karte, auftraege_mit_farbe: auftraege_mit_farbe)
    else
      keine_auftrag_farbe_anspielen_wert(karte: karte)
    end
  end

  def eigene_auftrag_farbe_anspielen_wert(karte:)
    auftrag = tiefster_eigener_auftrag_auf_fremder_hand_mit_farbe(karte.farbe)
    if auftrag.nil?
      eigene_auftrag_farbe_blank_machen_anspielen_wert(karte: karte)
    else
      eigene_auftrag_farbe_nicht_blank_machen_anspielen_wert(karte: karte, auftrag: auftrag)
    end
  end

  def eigene_auftrag_farbe_blank_machen_anspielen_wert(karte:)
    if jeder_kann_unterbieten?(karte: karte)
      [0, 0, 2, karte.wert, 0]
    else
      [0, 0, 1, karte.wert, 0]
    end
  end

  def eigene_auftrag_farbe_nicht_blank_machen_anspielen_wert(karte:, auftrag:)
    if jeder_kann_unterbieten?(karte: karte)
      eigene_auftrag_farbe_holen_anspielen_wert(karte: karte, auftrag: auftrag)
    elsif kurze_farbe?(farbe: karte.farbe) &&
          @spiel_informations_sicht.karten_mit_farbe(karte.farbe).length == 1 &&
          @spiel_informations_sicht.karten_mit_farbe(Farbe::RAKETE).length >= 1
      [0, 0, 0, 1, 0]
    else
      [0, 0, -1, -karte.wert, 0]
    end
  end

  def eigene_auftrag_farbe_holen_anspielen_wert(karte:, auftrag:)
    if karte.wert > auftrag.karte.wert
      [0, 1, 3, karte.wert, 0]
    elsif habe_hohe_karte_mit_farbe?(farbe: karte.farbe, wert: auftrag.karte.wert) ||
          kurze_farbe?(farbe: karte.farbe)
      [0, 0, 1, 0, 0]
    else
      [0, 0, -1, 0, 0]
    end
  end

  def fremden_auftrag_farbe_anspielen_wert(karte:, auftraege_mit_farbe:)
    if (1..@spiel_informations_sicht.anzahl_spieler - 1).any? do |spieler_index|
         (auftraege_mit_farbe[spieler_index]).positive? &&
         kann_ueberbieten?(karte: karte, spieler_index: spieler_index)
       end
      [0, 1, 0, 0, -karte.wert, 0]
    else
      [0, -1, 0, 0, -karte.wert, 0]
    end
  end

  def eigen_und_fremd_auftrag_farbe_anspielen_wert(karte:)
    multiple_auftrag_farbe_anspielen_wert(karte: karte)
  end

  def keine_auftrag_farbe_anspielen_wert(karte:)
    if karte.trumpf?
      trumpf_anspielen_wert(karte: karte)
    elsif habe_noch_auftraege?
      eigene_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte: karte)
    else
      fremde_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte: karte)
    end
  end

  def eigene_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte:)
    farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    if jeder_kann_unterbieten?(karte: karte)
      [0, 0, farb_laenge - 1, karte.wert, 0]
    else
      [0, 0, (farb_laenge * 0.1) - 0.1, karte.wert, 0]
    end
  end

  def fremde_auftraege_mit_anderer_farbe_unterstuetzen_anspielen_wert(karte:)
    farb_laenge = berechne_farb_laenge(farbe: karte.farbe)
    [0, 0, 12 - karte.wert - (farb_laenge * 2), 0, 0]
  end
end