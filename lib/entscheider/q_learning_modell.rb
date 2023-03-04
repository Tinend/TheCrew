# frozen_string_literal: true

require_relative 'ai_input_ersteller'
require_relative 'ai_aktions_raum'

# Modell, dass auf Reinforcement Learning mit dem Q-learning Algorithmus basiert.
class QLearningModell
  ANZAHL_EPOCHEN = 1
  FEHLER_ZWISCHEN_BERICHTEN = 1
  GEWUENSCHTER_MITTLERER_QUADRATISCHER_FEHLER = 0.1
  LEARNING_RATE = 0.2
  REPLAY_BATCH_SIZE = 400
  REPLAY_MEMORY_SIZE = 500
  DISCOUNT = 0.9

  def self.instanz
    @instanz ||= new
  end

  def initialize
    ai_input_laenge = AiInputErsteller.ai_input_laenge
    @q_nn_model = RubyFann::Standard.new(
      num_inputs: ai_input_laenge,
      hidden_neurons: [ai_input_laenge],
      num_outputs: 1
    )
    @q_nn_model.set_learning_rate(LEARNING_RATE)
    @q_nn_model.set_activation_function_hidden(:sigmoid_symmetric)
    @q_nn_model.set_activation_function_output(:sigmoid_symmetric)
    @replay_memory_pointer = 0
    @replay_memory = []
  end

  def aktionen
    @aktionen ||= Karte.alle + [nil]
  end

  def inspect
    "#<QLearningModell @replay_memory_pointer=#{@replay_memory_pointer} " \
      "@q_nn_model=#{@q_nn_model} @replay_memory.length=#{@replay_memory.length}>"
  end

  def speichere_replay_memory(item)
    @replay_memory[@replay_memory_pointer] = item
    @replay_memory_pointer = (@replay_memory_pointer + 1) % REPLAY_MEMORY_SIZE
  end

  def zufaelliger_replay_memory_batch
    @replay_memory.sample(REPLAY_BATCH_SIZE)
  end

  def merke(ai_input, bewertung, alter_ai_input, ai_aktionen)
    raise TypeError unless ai_input.nil? || ai_input.is_a?(AiInputErsteller::AiInput)
    raise TypeError unless alter_ai_input.nil? || alter_ai_input.is_a?(AiInputErsteller::AiInput)
    raise TypeError unless ai_aktionen.is_a?(Array) && ai_aktionen.all?(AiAktionsRaum::AiAktion)
    raise ArgumentError if ai_input && ai_aktionen.empty?
    return if alter_ai_input.nil?

    # Add reward, old_state and inputq state to memory
    speichere_replay_memory({ bewertung: bewertung, alter_ai_input: alter_ai_input, ai_input: ai_input,
                              ai_aktionen: ai_aktionen })

    return unless @replay_memory.length >= REPLAY_MEMORY_SIZE

    trainiere_modell
  end

  def erstelle_trainings_daten
    batch = zufaelliger_replay_memory_batch
    training_x_data = []
    training_y_data = []
    # For each batch calculate new q_value based on current network and reward
    batch.each do |m|
      puts 'Batch item'
      # Am Ende des Spiels wird nichts mehr hinzugefügt. q_value bleibt.
      unless m[:ai_input]
        # Add to training set
        training_x_data.push(m[:alter_ai_input])
        training_y_data.push(m[:bewertung])
        next
      end

      ai_input = m[:ai_input].dup
      q_table_row = m[:ai_aktionen].map do |a|
        ai_input.setze_aktion(a)
        bewerte(ai_input)
      end
      # Update the q value
      updated_q_value = m[:bewertung] + (DISCOUNT * q_table_row.max)
      # Add to training set
      training_x_data.push(m[:alter_ai_input])
      training_y_data.push([updated_q_value])
    end
    RubyFann::TrainData.new(inputs: training_x_data, desired_outputs: training_y_data)
  end

  def trainiere_modell
    train = erstelle_trainings_daten
    @q_nn_model.train_on_data(train, ANZAHL_EPOCHEN, FEHLER_ZWISCHEN_BERICHTEN,
                              GEWUENSCHTER_MITTLERER_QUADRATISCHER_FEHLER)
  end

  def bewerte(ai_input)
    @q_nn_model.run(ai_input.input_array).first
  end
end
