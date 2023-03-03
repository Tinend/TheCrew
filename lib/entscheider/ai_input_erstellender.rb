require_relative '../karte'

module AiInputErstellender
  MIN_SPIELER = 2
  MAX_SPIELER = 5
  ANZAHL_KARTEN = 40

  def karten_index(karte)
    Karte.alle.index(karte)
  end

  class AnzahlSpielerInputTeil
    def fuelle(spiel_informations_sicht, input, basis_index)
      input[basis_index + spiel_informations_sicht.anzahl_spieler - MIN_SPIELER] = 1
    end

    def laenge
      MAX_SPIELER - MIN_SPIELER
    end
  end

  class KapitaenIndexInputTeil
    def fuelle(spiel_informations_sicht, input, basis_index)
      input[basis_index + spiel_informations_sicht.kapitaen_index] = 1
    end

    def laenge
      MAX_SPIELER
    end
  end

  class HandKartenInputTeil
    def fuelle(spiel_informations_sicht, input, basis_index)
      spiel_informations_sicht.karten.each do |k|
        input[basis_index + karten_index(k)] = 1
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

    def fuelle(spiel_informations_sicht, input, basis_index)
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

    def fuelle(spiel_informations_sicht, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      auftraege = spiel_informations_sicht.auftraege[@spieler_index]
      auftraege.each do |a|
        input[basis_index + karten_index(a.karte)] = 1
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

    def fuelle(spiel_informations_sicht, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      input[basis_index + karten_index(kommunikation.karte)] = 1
    end

    def laenge
      Karte.alle.length
    end
  end

  class KommunikationsArtInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      kommunikations_art_index = Kommunikatino::ARTEN.index(kommunikation.art)
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

    def fuelle(spiel_informations_sicht, input, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      input[basis_index + kommunikation.gegangene_stiche] = 1
    end

    def laenge
      Karte.alle.length / MIN_SPIELER
    end
  end

  class GespielteKarteInputTeil
    def initialize(stich_index, karten_index)
      @stich_index = stich_index
      @karten_index = karten_index
    end

    def fuelle(spiel_informations_sicht, input, basis_index)
      return if @stich_index >= spiel_informations_sicht.stiche.length
      return if @karten_index >= spiel_informations_sicht.anzahl_spieler

      stich = spiel_informations_sicht.stiche[@stich_index]
      karte = stich.karten[@karten_index]
      input[basis_index + karten_index(karte)] = 1
    end

    def laenge
      Karte.alle.length * MAX_SPIELER
    end
  end

  def input_teile
    @input_teile ||= [
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
      ] + (0...(Karte.alle.length / MIN_SPIELER)).flat_map do |runde_index|
        (0...MAX_SPIELER).map do |karten_index|
          GespielteKarteInputTeil.new(runde_index, karten_index)
        end
      end
    end
  end

  def input_laenge
    input_teile.map { |t| t.laenge }.reduce(:+)
  end

  def spiel_informations_sicht_zu_input(spiel_informations_sicht)
    input = Array.new(input_laenge, 0)
    basis_index = 0
    input_teile.each do |t|
      t.fuelle(spiel_informations_sicht, input, basis_index)
      basis_index += t.laenge
    end
    input
  end
end
