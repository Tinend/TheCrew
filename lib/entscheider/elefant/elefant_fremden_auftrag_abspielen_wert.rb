# coding: utf-8
# berechnet Wert für Karten anspielen, wenn
# Karte ein fremder Auftrag ist
module ElefantFremdenAuftragAbspielenWert
  def fremden_auftrag_abspielen_wert(karte:, stich:, ziel_spieler_index:)
    if hat_gespielt?(spieler_index: ziel_spieler_index, stich: stich)
      vielleicht_auftrag_reinwerfen_abspielen_wert(karte: karte, stich: stich, ziel_spieler_index: ziel_spieler_index)
    else
      10_010
    end
  end

  def vielleicht_auftrag_reinwerfen_abspielen_wert(karte:, stich:, ziel_spieler_index:)
    if stich.sieger_index == ziel_spieler_index
      auftrag_reinwerfen_abspielen_wert(karte: karte, stich: stich, ziel_spieler_index: ziel_spieler_index)
    else
      -10_000
    end
  end

  def auftrag_reinwerfen_abspielen_wert(karte:, stich:, ziel_spieler_index:)
    if karte.schlaegt?(stich.staerkste_karte)
      -10_000
    else
      10_010
    end
  end
end
