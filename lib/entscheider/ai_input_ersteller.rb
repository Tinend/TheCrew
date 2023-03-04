require_relative '../karte'

class AiInputErsteller
  MIN_SPIELER = 2
  MAX_SPIELER = 5

  def self.karten_index(karte)
    Karte.alle.index(karte)
  end

  class AktionInputTeil
    def fuelle(_spiel_informations_sicht, aktions_art, _input, _basis_index); end

    def laenge
      Karte.alle.length + 1
    end
  end

  class AktionsArtInputTeil
    AKTIONS_ARTEN = [:kommunikation, :auftrag, :karte]

    def fuelle(_spiel_informations_sicht, aktions_art, input, basis_index)
      input[basis_index + AKTIONEN.index(aktion)] = 1
    end

    def laenge
      3
    end
  end

  class AnzahlSpielerInputTeil
    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      input[basis_index + spiel_informations_sicht.anzahl_spieler - MIN_SPIELER] = 1
    end

    def laenge
      MAX_SPIELER - MIN_SPIELER
    end
  end

  class KapitaenIndexInputTeil
    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      input[basis_index + spiel_informations_sicht.kapitaen_index] = 1
    end

    def laenge
      MAX_SPIELER
    end
  end

  class HandKartenInputTeil
    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      spiel_informations_sicht.karten.each do |k|
        input[basis_index + AiInputErsteller.karten_index(k)] = 1
      end
    end

    def laenge
      Karte.alle.length
    end
  end

  class AnzahlKartenInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      anzahl_karten = spiel_informations_sicht.anzahl_karten(spieler_index: @spieler_index)
      input[basis_index + anzahl_karten] = 1
    end

    def laenge
      Karte.alle.length / MIN_SPIELER
    end
  end

  class AuftraegeInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      auftraege = spiel_informations_sicht.auftraege[@spieler_index]
      auftraege.each do |a|
        input[basis_index + AiInputErsteller.karten_index(a.karte)] = 1
      end
    end

    def laenge
      Karte.alle.length
    end
  end

  class KommunizierteKarteInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      input[basis_index + AiInputErsteller.karten_index(kommunikation.karte)] = 1
    end

    def laenge
      Karte.alle.length
    end
  end

  class KommunikationsArtInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      kommunikations_art_index = Kommunikation::ARTEN.index(kommunikation.art)
      input[basis_index + kommunikations_art_index] = 1
    end

    def laenge
      Kommunikation::ARTEN.length
    end
  end

  class KommunikationsGegangeneSticheInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      input[basis_index + kommunikation.gegangene_stiche] = 1
    end

    def laenge
      Karte.alle.length / MIN_SPIELER
    end
  end

  class GegangeneKarteInputTeil
    def initialize(stich_index, karten_index)
      @stich_index = stich_index
      @karten_index = karten_index
    end

    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      return if @stich_index >= spiel_informations_sicht.stiche.length
      return if @karten_index >= spiel_informations_sicht.anzahl_spieler

      stich = spiel_informations_sicht.stiche[@stich_index]
      karte = stich.karten[@karten_index]
      input[basis_index + AiInputErsteller.karten_index(karte)] = 1
    end

    def laenge
      Karte.alle.length * MAX_SPIELER
    end
  end

  class AktuelleStichKarteInputTeil
    def initialize(karten_index)
      @karten_index = karten_index
    end

    def fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      return unless spiel_informations_sicht.aktiver_stich
      return if @karten_index >= spiel_informations_sicht.aktiver_stich.length

      karte = spiel_informations_sicht.aktiver_stich.karten[@karten_index]
      input[basis_index + AiInputErsteller.karten_index(karte)] = 1
    end

    def laenge
      Karte.alle.length * MAX_SPIELER
    end
  end

  def input_teile
    @input_teile ||= [
      AktionInputTeil.new,
      AnzahlSpielerInputTeil.new,
      KapitaenIndexInputTeil.new,
      HandKartenInputTeil.new
    ] + (1...MAX_SPIELER).flat_map do |spieler_index|
      [
        AnzahlKartenInputTeil.new(spieler_index),
        AuftraegeInputTeil.new(spieler_index),
        KommunizierteKarteInputTeil.new(spieler_index),
        KommunikationsArtInputTeil.new(spieler_index),
        KommunikationsGegangeneSticheInputTeil.new(spieler_index)
      ]
    end + (0...(Karte.alle.length / MIN_SPIELER)).flat_map do |runde_index|
      (0...MAX_SPIELER).map do |karten_index|
        GegangeneKarteInputTeil.new(runde_index, karten_index)
      end
    end + (0...MAX_SPIELER).map do |karten_index|
      AktuelleStichKarteInputTeil.new(karten_index)
    end
  end

  def input_laenge
    input_teile.map { |t| t.laenge }.reduce(:+)
  end

  def input(spiel_informations_sicht, aktions_art)
    input = Array.new(input_laenge, 0)
    basis_index = 0
    input_teile.each do |t|
      t.fuelle(spiel_informations_sicht, aktions_art, input, basis_index)
      basis_index += t.laenge
    end
    input
  end
end
