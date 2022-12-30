# frozen_string_literal: true

require 'farbe'

# Spielkarte
class Karte
  MIN_WERT = 1
  MAX_WERT = 9
  MAX_TRUMPF_WERT = 4

  def initialize(wert:, farbe:)
    @wert = wert
    @farbe = farbe
  end

  def self.max_trumpf
    @max_trumpf ||= new(wert: MAX_TRUMPF_WERT, farbe: Farbe::RAKETE)
  end

  def self.nil_karte
    @nil_karte ||= new(wert: 0, farbe: Farbe::ANTI_RAKETE)
  end

  def self.alle_normalen
    @alle_normalen ||= Farbe::NORMALE_FARBEN.flat_map { |f| (MIN_WERT..MAX_WERT).map { |w| new(farbe: f, wert: w) } }
  end

  def self.alle_truempfe
    @alle_truempfe ||= (MIN_WERT..MAX_TRUMPF_WERT).map { |w| new(farbe: Farbe::RAKETE, wert: w) }
  end

  def self.alle
    @alle ||= alle_normalen + alle_truempfe
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
