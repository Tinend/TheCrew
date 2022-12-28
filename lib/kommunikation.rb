class Kommunikation
  def initialize(karte:, art:)
    @karte = karte
    @art = art
  end

  attr_reader :karte, :art

  def self.hoechste(karte)
    new(karte: karte, art: :hoechste)
  end

  def self.tiefste(karte)
    new(karte: karte, art: :tiefste)
  end

  def self.einzige(karte)
    new(karte: karte, art: :einzige)
  end

  def eql?(other)
    self.class == other.class && @karte == other.karte && @art == other.art
  end

  alias == eql?

  def hash
    @hash ||= [self.class, @karte, @art].hash
  end
end
