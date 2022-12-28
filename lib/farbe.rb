# coding: utf-8
# frozen_string_literal: true

# Eine Farbe für die Spielkarten. I.e. Trumpf und die vier normalen Farben (plus eine Pseudofarbe).
class Farbe
  def initialize(name:, staerke:)
    @name = name
    @staerke = staerke
  end

  attr_reader :name, :staerke

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
  RAKETE = new(name: 'Rakete', staerke: 1)

  # Pseudo Farbe die es nicht wirklich gibt und die anti Trumpf ist.
  ANTI_RAKETE = new(name: 'AntiRakete', staerke: -1)

  GRUEN = new(name: 'grün', staerke: 0)
  ROT = new(name: 'rot', staerke: 0)
  BLAU = new(name: 'blau', staerke: 0)
  GELB = new(name: 'gelb', staerke: 0)

  NORMALE_FARBEN = [GRUEN, ROT, BLAU, GELB].freeze
end
