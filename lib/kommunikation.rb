# coding: utf-8
# frozen_string_literal: true

# Stellt die Kommunikation eines Spielers, dass eine bestimmte Karte seine höchste, tiefste oder einzige Karte ist, dar.
class Kommunikation
  ARTEN = %i[einzige tiefste hoechste].freeze

  def initialize(karte:, art:, gegangene_stiche:)
    raise ArgumentError unless ARTEN.include?(art)

    @karte = karte
    @art = art
    @gegangene_stiche = gegangene_stiche
  end

  attr_reader :karte, :art, :gegangene_stiche

  def self.hoechste(karte:, gegangene_stiche:)
    new(karte: karte, art: :hoechste, gegangene_stiche: gegangene_stiche)
  end

  def self.tiefste(karte:, gegangene_stiche:)
    new(karte: karte, art: :tiefste, gegangene_stiche: gegangene_stiche)
  end

  def self.einzige(karte:, gegangene_stiche:)
    new(karte: karte, art: :einzige, gegangene_stiche: gegangene_stiche)
  end

  def einzige?
    @art == :einzige
  end

  def hoechste?
    @art == :hoechste
  end

  def tiefste?
    @art == :tiefste
  end

  def eql?(other)
    self.class == other.class && @karte == other.karte && @art == other.art &&
      @gegangene_stiche == other.gegangene_stiche
  end

  alias == eql?

  def hash
    @hash ||= [self.class, @karte, @art, @gegangene_stiche].hash
  end
end
