# frozen_string_literal: true

# Stellt die Kommunikation eines Spielers, dass eine bestimmte Karte seine höchste, tiefste oder einzige Karte ist, dar.
class Kommunikation
  ARTEN = %i[strikt_hoechste einzige strikt_tiefste tiefste_oder_einzige hoechste_oder_einzige].freeze

  def initialize(karte:, art:, gegangene_stiche:)
    raise ArgumentError unless ARTEN.include?(art)

    @karte = karte
    @art = art
    @gegangene_stiche = gegangene_stiche
  end

  attr_reader :karte, :art, :gegangene_stiche

  def self.hoechste(karte:, gegangene_stiche:)
    new(karte: karte, art: :strikt_hoechste, gegangene_stiche: gegangene_stiche)
  end

  def self.tiefste(karte:, gegangene_stiche:)
    new(karte: karte, art: :strikt_tiefste, gegangene_stiche: gegangene_stiche)
  end

  def self.einzige(karte:, gegangene_stiche:)
    new(karte: karte, art: :einzige, gegangene_stiche: gegangene_stiche)
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
