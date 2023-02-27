# coding: utf-8
# frozen_string_literal: true

# Helfer für Entscheider, um Statistiken zu erstellen, zB wie oft
# eine bestimmte Situation eintrifft.
class Statistiker
  def initialize
    @letztes_spiel_statistiker = nil
    @anzahl_spieler = nil
    @gesamt_statistiker = GesamtStatistiker.new
    @gewonnen_statistiker = GesamtStatistiker.new
    @verloren_statistiker = GesamtStatistiker.new
  end

  def beachte_neues_spiel(anzahl_spieler)
    @letztes_spiel_statistiker = nil
    @spiel_statistiker = SpielStatistiker.new
    @anzahl_spieler = anzahl_spieler
  end

  def neuer_zaehler_manager
    ZaehlerManager.new(self)
  end

  def beachte_stich
    @spiel_statistiker.erhoehe_quotient(@anzahl_spieler)
  end

  def beachte_gewonnen
    @letztes_spiel_statistiker = @spiel_statistiker
    @gesamt_statistiker.fuege_hinzu(@spiel_statistiker)
    @gewonnen_statistiker.fuege_hinzu(@spiel_statistiker)
    @spiel_statistiker = nil
  end

  def beachte_verloren
    @letztes_spiel_statistiker = @spiel_statistiker
    @gesamt_statistiker.fuege_hinzu(@spiel_statistiker)
    @verloren_statistiker.fuege_hinzu(@spiel_statistiker)
    @spiel_statistiker = nil
  end

  def erhoehe_zaehler(zaehler_name)
    @spiel_statistiker.erhoehe_zaehler(zaehler_name)
  end

  def letztes_spiel_statistiken
    @letztes_spiel_statistiker.statistiken
  end

  def verloren_statistiken
    @gesamt_statistiker.statistiken
  end

  def gewonnen_statistiken
    @gesamt_statistiker.statistiken
  end

  def gesamt_statistiken
    @gesamt_statistiker.statistiken
  end

  # Zaehler Manager auf den ein Entscheider Zugriff hat.
  class ZaehlerManager
    def initialize(statistiker)
      @statistiker = statistiker
    end

    def erhoehe_zaehler(zaehler_name)
      @statistiker.erhoehe_zaehler(zaehler_name)
    end
  end

  # Gemeinsamkeiten für Helferklassen des Statistikers.
  class SubStatistiker
    def initialize
      @zaehler = {}
      @zaehler.default = 0
      @quotient = 0.0
    end

    attr_reader :zaehler, :quotient

    def statistiken
      @zaehler.transform_values { |wert| wert / quotient }
    end
  end

  # Behandelt die Statistiken für ein Spiel.
  class SpielStatistiker < SubStatistiker
    def erhoehe_zaehler(zaehler_name)
      @zaehler[zaehler_name] += 1
    end

    def erhoehe_quotient(anzahl)
      @quotient += anzahl
    end
  end

  # Behandelt die Statistiken für mehrere Spiele, e.g. alle gewonnenen Spiele.
  class GesamtStatistiker < SubStatistiker
    def fuege_hinzu(sub_statistiker)
      raise TypeError unless sub_statistiker.is_a?(SubStatistiker)

      sub_statistiker.zaehler.each do |zaehler_name, wert|
        @zaehler[zaehler_name] += wert
      end
      @quotient += sub_statistiker.quotient
    end
  end
end
