# coding: utf-8
# frozen_string_literal: true

require 'colorize'

# Eine Farbe für die Spielkarten. I.e. Trumpf und die vier normalen Farben (plus eine Pseudofarbe).
class Farbe
  def initialize(name:, staerke:, sortier_wert:)
    @name = name
    @staerke = staerke
    @sortier_wert = sortier_wert
  end

  attr_reader :name, :staerke, :sortier_wert

  def eql?(other)
    self.class == other.class && name == other.name && staerke == other.staerke
  end

  def hash
    @hash ||= [self.class, @name, @staerke].hash
  end

  def schlaegt?(other)
    @staerke > other.staerke
  end

  def trumpf?
    @staerke > 0
  end

  alias == eql?

  # Trumpf
  RAKETE = new(name: 'Rakete', staerke: 1, sortier_wert: 4)

  # Pseudo Farbe die es nicht wirklich gibt und die anti Trumpf ist.
  ANTI_RAKETE = new(name: 'AntiRakete', staerke: -1, sortier_wert: -1)

  GRUEN = new(name: 'grün', staerke: 0, sortier_wert: 3)
  ROT = new(name: 'rot', staerke: 0, sortier_wert: 2)
  BLAU = new(name: 'blau', staerke: 0, sortier_wert: 1)
  GELB = new(name: 'gelb', staerke: 0, sortier_wert: 0)

  NORMALE_FARBEN = [GRUEN, ROT, BLAU, GELB].freeze

  def faerben(string)
    return string.green if @name == 'grün'
    return string.red if @name == 'rot'
    return string.blue if @name == 'blau'
    return string.yellow if @name == 'gelb'

    string
  end
end
