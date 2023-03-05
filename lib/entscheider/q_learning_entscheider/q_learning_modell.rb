# frozen_string_literal: true

require_relative 'ai_input_ersteller'
require_relative 'ai_aktions_raum'
require_relative 'reinforcement_learning_modell'
require 'pry'
require 'progressbar'

# Modell, dass auf Reinforcement Learning mit dem Q-learning Algorithmus basiert.
class QLearningModell < ReinforcementLearningModell
  ANZAHL_EPOCHEN = 10
  FEHLER_ZWISCHEN_BERICHTEN = 1
  GEWUENSCHTER_MITTLERER_QUADRATISCHER_FEHLER = 25.0
  LEARNING_RATE = 100.0
  REPLAY_BATCH_SIZE = 400
  REPLAY_MEMORY_SIZE = 500
  DISCOUNT = 0.95

  def self.instanz
    @instanz ||= new
  end

  def initialize
    super()
    ai_input_laenge = AiInputErsteller.ai_input_laenge
    hidden_size = ai_input_laenge
    @q_nn_model = RubyFann::Standard.new(
      num_inputs: ai_input_laenge,
      hidden_neurons: [hidden_size, Math.sqrt(hidden_size).ceil],
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
    raise TypeError unless bewertung.is_a?(Float)
    raise ArgumentError if ai_input && ai_aktionen.empty?
    return if alter_ai_input.nil?

    speichere_replay_memory({ bewertung: bewertung, alter_ai_input: alter_ai_input, ai_input: ai_input,
                              ai_aktionen: ai_aktionen })

    return unless @replay_memory.length >= REPLAY_MEMORY_SIZE

    trainiere_modell
  end

  def item_zu_trainings_daten(item)
    # Am Ende des Spiels wird nichts mehr hinzugefügt. q_value bleibt.
    return [item[:alter_ai_input].input_array, [item[:bewertung]]] unless item[:ai_input]

    ai_input = item[:ai_input].dup
    q_table_row = item[:ai_aktionen].map do |a|
      ai_input.setze_aktion(a)
      bewerte(ai_input)
    end
    # Update the q value
    updated_q_value = item[:bewertung] + (DISCOUNT * q_table_row.max)
    # Add to training set
    [item[:alter_ai_input].input_array, [updated_q_value]]
  end

  def erstelle_trainings_daten
    batch = zufaelliger_replay_memory_batch
    training_x_data = []
    training_y_data = []
    puts '    Trainingsdaten werden erstellt'
    progress_bar = ProgressBar.create(total: batch.length)
    start = Time.now
    # For each batch calculate new q_value based on current network and reward
    batch.each do |m|
      progress_bar.increment
      x_item, y_item = item_zu_trainings_daten(m)
      training_x_data.push(x_item)
      training_y_data.push(y_item)
    end
    puts "    #{Time.now - start} Sekunden Trainings Daten erstellt"
    ueberpruefe_trainings_daten(training_x_data, training_y_data)
    RubyFann::TrainData.new(inputs: training_x_data, desired_outputs: training_y_data)
  end

  # Überprüft, ob die Trainingsdaten in Ordnung sind. Theoretisch sollte das nicht nötig sein,
  # in der Praxis ist es das manchmal, wenn der Code hier sich ändert. Dies führt zu nützlichen
  # Fehlern anstatt Segfaults.
  def ueberpruefe_trainings_daten(training_x_data, training_y_data)
    raise TypeError unless training_x_data.is_a?(Array)
    raise TypeError unless training_x_data.all?(Array)
    raise TypeError unless training_x_data.all? { |x| x.all?(Integer) }
    raise TypeError unless training_y_data.is_a?(Array)
    raise TypeError unless training_y_data.all?(Array)
    raise TypeError unless training_y_data.all? { |x| x.all?(Float) }
    raise ArgumentError unless training_x_data.length == training_y_data.length
    raise TypeError unless training_x_data.all? { |x| x.length == AiInputErsteller.ai_input_laenge }
  end

  def trainiere_modell
    train = erstelle_trainings_daten
    puts '    Modell wird neu trainiert'
    start = Time.now
    @q_nn_model.train_on_data(train, ANZAHL_EPOCHEN, FEHLER_ZWISCHEN_BERICHTEN,
                              GEWUENSCHTER_MITTLERER_QUADRATISCHER_FEHLER)
    puts "    #{Time.now - start} Sekunden trainiert"
  end

  def bewerte(ai_input)
    @q_nn_model.run(ai_input.input_array).first
  end
end
