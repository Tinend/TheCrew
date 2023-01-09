# frozen_string_literal: true

require 'farbe'

# Spielkarte
class Karte
  def initialize(wert:, farbe:)
    @wert = wert
    @farbe = farbe
  end

  def self.max_trumpf
    @max_trumpf ||= new(wert: Farbe::RAKETE.max_wert, farbe: Farbe::RAKETE)
  end

  def self.nil_karte
    @nil_karte ||= new(wert: 0, farbe: Farbe::ANTI_RAKETE)
  end

  def self.alle_normalen
    @alle_normalen ||= Farbe::NORMALE_FARBEN.flat_map do |f|
      (f.min_wert..f.max_wert).map do |w|
        new(farbe: f, wert: w)
      end
    end
  end

  def self.alle_truempfe
    @alle_truempfe ||= (Farbe::RAKETE.min_wert..Farbe::RAKETE.max_wert).map { |w| new(farbe: Farbe::RAKETE, wert: w) }
  end

  def self.alle
    @alle ||= alle_normalen + alle_truempfe
  end

  def self.alle_mit_farbe(farbe)
    @alle_normalen.select { |karte| karte.farbe == farbe }
  end

  def to_s
    @farbe.faerben(wert.to_s)
  end

  def trumpf?
    @farbe.trumpf?
  end

  attr_reader :wert, :farbe

  def schlaegt?(karte)
    @farbe.schlaegt?(karte.farbe) || (@farbe == karte.farbe && @wert > karte.wert)
  end

  def eql?(other)
    self.class == other.class && @wert == other.wert && @farbe == other.farbe
  end

  def <=>(other)
    [@farbe.sortier_wert, @wert] <=> [other.farbe.sortier_wert, other.wert]
  end

  alias == eql?

  def hash
    @hash ||= [self.class, @wert, @farbe].hash
  end
end
