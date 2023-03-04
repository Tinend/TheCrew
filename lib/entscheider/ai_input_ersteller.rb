# frozen_string_literal: true

require_relative '../karte'
require_relative 'ai_aktions_raum'

# Erstellt den Input für eine AI aus einer SpielInformationsSicht.
class AiInputErsteller
  MIN_SPIELER = 2
  MAX_SPIELER = 5

  def self.karten_index(karte)
    Karte.alle.index(karte)
  end

  # Stellt den Input für eine AI dar.
  class AiInput
    def initialize(input_array)
      raise TypeError unless input_array.is_a?(Array)
      raise TypeError unless input_array.all?(Integer)
      raise ArgumentError unless input_array.length == AiInputErsteller.ai_input_laenge

      @input_array = input_array
    end

    attr_reader :input_array

    def setze_aktion(ai_aktion)
      AiAktionsRaum.maximal_laenge.times { |i| @input_array[i] = 0 }
      @input_array[ai_aktion.index] = 1
    end
  end

  # Input Teil, der nichts macht, aber am Anfang Platz lässt für Aktionen, die später
  # eingefüllt werden.
  # Dies muss am Anfang sein, damit man die Aktion am Anfang einfüllen kann.
  class AktionInputTeil
    def fuelle(_spiel_informations_sicht, _aktions_art, _input_array, basis_index)
      raise unless basis_index.zero?
    end

    def laenge
      AiAktionsRaum.maximal_laenge
    end
  end

  # Input Teil, der darstellt, was für eine Aktion gefragt ist.
  # I.e. Auftrag wählen, Karte wählen oder kommunizieren.
  class AktionsArtInputTeil
    def fuelle(_spiel_informations_sicht, aktions_art, input_array, basis_index)
      input_array[basis_index + AiAktionsRaum::ARTEN.index(aktions_art)] = 1
    end

    def laenge
      AiAktionsRaum::ARTEN.length
    end
  end

  # Input Teil, der die Anzahl Spieler darstellt.
  class AnzahlSpielerInputTeil
    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      anzahl_spieler = spiel_informations_sicht.anzahl_spieler
      if anzahl_spieler < MIN_SPIELER || anzahl_spieler > MAX_SPIELER
        raise ArgumentError, "Unmögliche Anzahl Spieler #{anzahl_spieler}."
      end

      input_array[basis_index + anzahl_spieler - MIN_SPIELER] = 1
    end

    def laenge
      MAX_SPIELER - MIN_SPIELER
    end
  end

  # Input Teil, der den Kapitäns Index darstellt.
  class KapitaenIndexInputTeil
    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      input_array[basis_index + spiel_informations_sicht.kapitaen_index] = 1
    end

    def laenge
      MAX_SPIELER
    end
  end

  # Input Teil, der die Handkarten des Spielers darstellt.
  class HandKartenInputTeil
    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      spiel_informations_sicht.karten.each do |k|
        input_array[basis_index + AiInputErsteller.karten_index(k)] = 1
      end
    end

    def laenge
      Karte.alle.length
    end
  end

  # Input Teil, der die Anzahl Karten eines anderen Spielers darstellt.
  class AnzahlKartenInputTeil
    def initialize(spieler_index)
      raise ArgumentError if spieler_index.zero?
      raise ArgumentError if spieler_index > MAX_SPIELER

      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      anzahl_karten = spiel_informations_sicht.anzahl_karten(spieler_index: @spieler_index)
      input_array[basis_index + anzahl_karten] = 1
    end

    def laenge
      Karte.alle.length / MIN_SPIELER
    end
  end

  # Input Teil, der die Aufträge eines Spielers darstellt.
  class AuftraegeInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      auftraege = spiel_informations_sicht.auftraege[@spieler_index]
      auftraege.each do |a|
        input_array[basis_index + AiInputErsteller.karten_index(a.karte)] = 1
      end
    end

    def laenge
      Karte.alle.length
    end
  end

  # Input Teil, der eine kommunizierte Karte darstellt.
  class KommunizierteKarteInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      input_array[basis_index + AiInputErsteller.karten_index(kommunikation.karte)] = 1
    end

    def laenge
      Karte.alle.length
    end
  end

  # Input Teil, der eine Kommunikationsart darstellt.
  # I.e. einzige, höchste oder tiefste.
  class KommunikationsArtInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      kommunikations_art_index = Kommunikation::ARTEN.index(kommunikation.art)
      input_array[basis_index + kommunikations_art_index] = 1
    end

    def laenge
      Kommunikation::ARTEN.length
    end
  end

  # Input Teil, der darstellt, wie viele Stiche zum Moment einer
  # Kommunikation gegangen waren.
  class KommunikationsGegangeneSticheInputTeil
    def initialize(spieler_index)
      @spieler_index = spieler_index
    end

    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      return if @spieler_index >= spiel_informations_sicht.anzahl_spieler

      kommunikation = spiel_informations_sicht.kommunikationen[@spieler_index]
      return unless kommunikation

      input_array[basis_index + kommunikation.gegangene_stiche] = 1
    end

    def laenge
      Karte.alle.length / MIN_SPIELER
    end
  end

  # Input Teil, der eine Karte, die in einem vergangenen Stich gespielt wurde, darstellt.
  class GegangeneKarteInputTeil
    def initialize(stich_index, karten_index)
      @stich_index = stich_index
      @karten_index = karten_index
    end

    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      return if @stich_index >= spiel_informations_sicht.stiche.length
      return if @karten_index >= spiel_informations_sicht.anzahl_spieler

      stich = spiel_informations_sicht.stiche[@stich_index]
      karte = stich.karten[@karten_index]
      input_array[basis_index + AiInputErsteller.karten_index(karte)] = 1
    end

    def laenge
      Karte.alle.length * MAX_SPIELER
    end
  end

  # Input Teil, der eine Karte des aktuellen Stichs darstellt.
  class AktuelleStichKarteInputTeil
    def initialize(karten_index)
      @karten_index = karten_index
    end

    def fuelle(spiel_informations_sicht, _aktions_art, input_array, basis_index)
      return unless spiel_informations_sicht.aktiver_stich
      return if @karten_index >= spiel_informations_sicht.aktiver_stich.length

      karte = spiel_informations_sicht.aktiver_stich.karten[@karten_index]
      input_array[basis_index + AiInputErsteller.karten_index(karte)] = 1
    end

    def laenge
      Karte.alle.length * MAX_SPIELER
    end
  end

  def self.simple_input_teile
    [
      AktionInputTeil.new,
      AktionsArtInputTeil.new,
      AnzahlSpielerInputTeil.new,
      KapitaenIndexInputTeil.new,
      HandKartenInputTeil.new
    ]
  end

  def self.andere_spieler_input_teile
    (1...MAX_SPIELER).map do |spieler_index|
      AnzahlKartenInputTeil.new(spieler_index)
    end
  end

  def self.spieler_input_teile
    (0...MAX_SPIELER).flat_map do |spieler_index|
      [
        KommunizierteKarteInputTeil.new(spieler_index),
        KommunikationsArtInputTeil.new(spieler_index),
        KommunikationsGegangeneSticheInputTeil.new(spieler_index),
        AuftraegeInputTeil.new(spieler_index),
        AktuelleStichKarteInputTeil.new(spieler_index)
      ]
    end
  end

  def self.gegangene_karten_input_teile
    (0...(Karte.alle.length / MIN_SPIELER)).flat_map do |runde_index|
      (0...MAX_SPIELER).map do |karten_index|
        GegangeneKarteInputTeil.new(runde_index, karten_index)
      end
    end
  end

  def self.input_teile
    @input_teile ||= simple_input_teile + andere_spieler_input_teile +
                     gegangene_karten_input_teile + spieler_input_teile
  end

  def self.ai_input_laenge
    @ai_input_laenge ||= input_teile.map(&:laenge).reduce(:+)
  end

  def self.ai_input(spiel_informations_sicht, aktions_art)
    raise ArgumentError unless AiAktionsRaum::ARTEN.include?(aktions_art)

    input_array = Array.new(ai_input_laenge, 0)
    basis_index = 0
    input_teile.each do |t|
      t.fuelle(spiel_informations_sicht, aktions_art, input_array, basis_index)
      basis_index += t.laenge
    end
    AiInput.new(input_array)
  end
end
