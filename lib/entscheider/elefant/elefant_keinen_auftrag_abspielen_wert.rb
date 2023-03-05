# coding: utf-8
# frozen_string_literal: true

require_relative 'elefant_multiple_auftrag_farbe_abspielen_wert'
require_relative 'elefant_eigene_auftrag_stich_farbe_abspielen_wert'
require_relative 'elefant_fremde_auftrag_stich_farbe_abspielen_wert'
require_relative 'elefant_keine_auftrag_stich_farbe_abspielen_wert'

# berechnet Wert für Karten anspielen, wenn
# Karte kein Auftrag ist
module ElefantKeinenAuftragAbspielenWert
  include ElefantMultipleAuftragFarbeAbspielenWert
  include ElefantEigeneAuftragStichFarbeAbspielenWert
  include ElefantFremdeAuftragStichFarbeAbspielenWert
  include ElefantKeineAuftragStichFarbeAbspielenWert

  def keinen_auftrag_abspielen_wert(karte:, stich:, elefant_rueckgabe:)
    auftraege_mit_farbe = auftraege_mit_farbe_berechnen(stich.farbe)
    eigene_auftraege_mit_farbe = auftraege_mit_farbe[0]
    fremde_auftraege_mit_farbe = auftraege_mit_farbe.sum - eigene_auftraege_mit_farbe
    if eigene_auftraege_mit_farbe.positive? && fremde_auftraege_mit_farbe.positive?
      multiple_auftrag_farbe_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    elsif eigene_auftraege_mit_farbe.positive?
      eigene_auftrag_stich_farbe_abspielen_wert(karte: karte, elefant_rueckgabe: elefant_rueckgabe)
    elsif fremde_auftraege_mit_farbe.positive?
      fremde_auftrag_stich_farbe_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    else
      keine_auftrag_stich_farbe_abspielen_wert(karte: karte, stich: stich, elefant_rueckgabe: elefant_rueckgabe)
    end
  end
end
