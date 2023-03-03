require_relative '../entscheider'
require_relative '../karte'
require_relative 'spiel_informations_sicht_benutzender'

class QLearningEntscheider < Entscheider
  LEARNING_RATE = 0.2

  include SpielInformationsSichtBenutzender

  def kommuniziert?
    @zufalls_generator.rand(karten.length).zero?
  end

  def waehle_kommunikation(kommunizierbares)
    kommunizierbares.sample(random: @zufalls_generator) if kommuniziert?
  end
  
  def waehl_auftrag(auftraege)
    auftraege.sample(random: @zufalls_generator)
  end

  def waehle_karte(_stich, waehlbare_karten)
    waehlbare_karten.sample(random: @zufalls_generator)
  end

  def initialize_q_neural_network
    @q_nn_model = RubyFann::Standard.new(
      num_inputs: input_laenge,
      hidden_neurons: [ input_laenge ],
      num_outputs: 1
    )

    @q_nn_model.set_learning_rate(LEARNING_RATE)

    @q_nn_model.set_activation_function_hidden(:sigmoid_symmetric)
    @q_nn_model.set_activation_function_output(:sigmoid_symmetric)
  end

end
