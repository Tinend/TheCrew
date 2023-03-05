# frozen_string_literal: true

require_relative 'reinforcement_learning_modell'

# Ruby Code als Wrapper für C Code.
class NativeModell < ReinforcementLearningModell
  def self.instanz
    @instanz ||= new
  end

  def initialize
    super()
    @native = Native::TensorFlowModell.new
  end

  def bewerte(ai_input)
    raise TypeError unless ai_input.is_a?(AiInputErsteller::AiInput)

    @native.bewerte(ai_input.input_array)
  end

  def merke(ai_input, bewertung, alter_ai_input, ai_aktionen)
    raise TypeError unless ai_input.nil? || ai_input.is_a?(AiInputErsteller::AiInput)
    raise TypeError unless alter_ai_input.nil? || alter_ai_input.is_a?(AiInputErsteller::AiInput)
    raise TypeError unless ai_aktionen.is_a?(Array) && ai_aktionen.all?(AiAktionsRaum::AiAktion)
    raise TypeError unless bewertung.is_a?(Float)
    raise ArgumentError if ai_input && ai_aktionen.empty?
    return if alter_ai_input.nil?

    @native.merke(ai_input.input_array, bewertung, alter_ai_input.input_array, ai_aktionen.map(&:index))
  end
end
