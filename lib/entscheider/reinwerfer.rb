require_relative 'zufalls_entscheider'
require_relative '../entscheider'

# Entscheider, der immer zufällig entschiedet, was er spielt.
# Wenn er eine Karte reinwerfen kann, die jemand anderem hilft,
# tut er das.
class Reinwerfer < Entscheider
  def waehl_auftrag(auftraege)
    auftraege.sample
  end

  def spieler_indizes_danach(stich)
    (1..@spiel_informations_sicht.anzanl_spieler - stich.length).to_a
  end

  # Sagt ja, wenn der Sieger des Stichs bleiben sollte, wenn die Spieler danach halbwegs schlau sind.
  def sieger_sollte_bleiben?(waehlbare_karten, stich)
    return true if stich.staerkste_karte.trumpf? && !stich.farbe.trumpf?

    max_wert = stich.farbe.trumpf? ? Karte::MAX_TRUMPF_WERT : Karte::MAX_WERT
    if (stich.staerkste_karte.wert+1..max_wert).all? { |w| karte = Karte.new(wert: w, farbe: stich.farbe); waehlbare_karten.include?(karte) || @spiel_informations_sicht.ist_gegangen?(karte) }
      return true
    end
    if stich.staerkste_karte.wert == 8
      spieler_indizes_danach.any? do |spieler_index|
        if @spiel_informations_sicht.hat_ungegangen_kommuniziert(spieler_index, single_neun(stich.farbe)) ||
           @spiel_informations_sicht.hat_ungegangen_kommuniziert(spieler_index, hoechste_neun(stich.farbe)) && @spiel_informations_sicht.hat_nach_kommunikation_farbe_gespielt(spieler_index, stich.farbe)
          return false
        end
      end
    elsif stich.staerkste_karte.wert == 7
      spieler_indizes_danach.any? do |spieler_index|
        if @spiel_informations_sicht.hat_ungegangen_kommuniziert(spieler_index, single_neun(stich.farbe)) ||
           @spiel_informations_sicht.hat_ungegangen_kommuniziert(spieler_index, hoechste_neun(stich.farbe)) && @spiel_informations_sicht.hat_nach_kommunikation_farbe_gespielt(spieler_index, stich.farbe) ||
           @spiel_informations_sicht.hat_ungegangen_kommuniziert(spieler_index, single_acht(stich.farbe)) ||
           @spiel_informations_sicht.hat_ungegangen_kommuniziert(spieler_index, hoechste_acht(stich.farbe)) && @spiel_informations_sicht.hat_nach_kommunikation_farbe_gespielt(spieler_index, stich.farbe) ||
           @spiel_informations_sicht.hat_ungegangen_kommuniziert(spieler_index, tiefste_acht(stich.farbe))
          return false
        end
      end
    end
    false
  end

  # Sagt ja, wenn der Stich bereits eine Auftragskarte des Siegers enthält.
  def toetlicher_stich?(stich)
    !(stich.karten & stich.sieger.auftraege.map(&:karte)).empty?
  end

  def hilfreiche_karten_fuer_sieger(stich, waehlbare_karten)
    (waehlbare_karten & stich.sieger.auftraege.map(&:karte)).reject { |k| k.schlaegt?(stich.staerkste_karte) }
  end

  def waehle_karte(stich, waehlbare_karten)
    return waehlbare_karten.sample if stich.empty?

    auftragskarten_anderer = (@spiel_informations_sicht.unerfuellte_auftraege.flatten - stich.sieger.auftraege).map(&:karte)

    if toetlicher_stich?(stich) && sieger_sollte_bleiben?(stich)
      # Wenn möglich eine Auftragskarte rein schmeissen.
      hilfreiche_karten = hilfreiche_karten_fuer_sieger(stich, waehlbare_karten)
      return hilfreiche_karten.sample unless hilfreiche_karten.empty?

      nicht_destruktive_karten = waehlbare_karten.reject { |k| k.schlaegt?(stich.staerkste_karte) } - auftragskarten_anderer
      return nicht_destruktive_karten.sample unless nicht_destruktive_karten.empty?
    end

    nehmende_spieler = nehmende_spieler_danach(stich)
    nehmende_spieler.each do |spieler_index|
      hilfreiche_karten = @spiel_informations_sicht.unerfuellte_auftraege[spieler_index]
      return hilfreiche_karten.sample unless hilfreiche_karten.empty?      
    end

    return waehlbare_karten.sample if stich.empty?
  end

  def sehe_spiel_informations_sicht(spiel_informations_sicht)
    @spiel_informations_sicht = spiel_informations_sicht
  end
end
