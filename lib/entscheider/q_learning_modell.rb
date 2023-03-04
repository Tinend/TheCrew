require_relative 'ai_input_ersteller'

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
    input_laenge = AiInputErsteller.new.input_laenge
    @q_nn_model = RubyFann::Standard.new(
      num_inputs: input_laenge,
      hidden_neurons: [input_laenge],
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
    "#<QLearningModell @replay_memory_pointer=#{@replay_memory_pointer} @q_nn_model=#{@q_nn_model} @replay_memory.length=#{@replay_memory.length}>"
  end

  def merke(input, bewertung, alter_input)
    # Add reward, old_state and inputq state to memory
    @replay_memory[@replay_memory_pointer] = {bewertung: bewertung, alter_input: alter_input, input: input}
    # Increment memory pointer
    @replay_memory_pointer = (@replay_memory_pointer + 1) % REPLAY_MEMORY_SIZE
    if @replay_memory.length >= REPLAY_MEMORY_SIZE
      trainiere_modell
    end
  end
  
  def trainiere_modell
    # Randomly sample a batch of actions from the memory and train network with these actions
    batch = @replay_memory.sample(REPLAY_BATCH_SIZE)
    training_x_data = []
    training_y_data = []
    # For each batch calculate new q_value based on current network and reward
    batch.each do |m|
      puts "Batch item"
      # Am Ende des Spiels wird nichts mehr hinzugefügt.
      unless m[:input]
        # Add to training set
        training_x_data.push(m[:old_input_state])
        training_y_data.push(m[:bewertung])
        next
      end

      q_table_row = aktionen.map do |a|
        # Create neural network input vector for this action
        input_state_action = m[:input].clone
        # Set a 1 in the action location of the input vector
        if a.nil?
          input_state_action[Karte.alle.length] = 1
        else
          input_state_action[AiInputErsteller.karten_index(a)] = 1
        end
        # Run the network for this action and get q table row entry
        @q_nn_model.run(input_state_action).first
      end
      # Update the q value
      updated_q_value = m[:bewertung] + DISCOUNT * q_table_row.max
      # Add to training set
      training_x_data.push(m[:old_input_state])
      training_y_data.push([updated_q_value])
    end
    # Train network with batch
    train = RubyFann::TrainData.new(inputs: training_x_data, desired_outputs: training_y_data)
    @q_nn_model.train_on_data(train, ANZAHL_EPOCHEN, FEHLER_ZWISCHEN_BERICHTEN, GEWUENSCHTER_MITTLERER_QUADRATISCHER_FEHLER)
  end

  def bewerte(input)
    @q_nn_model.run(input).first
  end
end
