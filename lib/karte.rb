# frozen_string_literal: true

require 'farbe'

MIN_VALUE = 1
MAX_VALUE = 9
MAX_TRUMPF_VALUE = 4

# Spielkarte
class Karte
  def initialize(wert:, farbe:)
    @wert = wert
    @farbe = farbe
  end

  def self.max_trumpf
    @max_trumpf ||= new(MAX_TRUMPF_VALUE, Farbe::RAKETE)
  end

  def self.nil_karte
    @nil_karte ||= new(0, Farbe::ANTI_RAKETE)
  end

  def self.alle_normalen
    @alle_normalen ||= NORMALE_FARBEN.flat_map { |f| (MIN_VALUE..MAX_VALUE).map { |w| new(f, w) } }
  end

  def self.alle_truempfe
    @alle_truempfe ||= (MIN_VALUE..MAX_TRUMPF_VALUE).map { |w| new(f, w) }
  end

  def self.alle
    @alle ||= @alle_normalen + @alle_truempfe
  end

  attr_reader :wert, :farbe

  def schlaegt?(karte)
    @farbe.schlaegt?(karte.farbe) || @farbe == karte.farbe && @wert > karte.wert
  end

  def eql?(other)
    self.class == other.class && @wert == other.wert && @farbe == other.farbe
  end

  alias == eql?

  def hash
    @hash ||= [self.class, @wert, @farbe].hash
  end
end
