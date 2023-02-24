# frozen_string_literal: true

# Hilfsmodul für Reporter um Statistiken auszugeben.
module StatistikenPutser
  def berichte_statistiken(statistiken_name, statistiken)
    return if statistiken.empty?

    puts "#{statistiken_name} Statistiken:"
    namen_max_laenge = statistiken.keys.map(&:length).max
    statistiken.each do |name, wert|
      padding = ' ' * (namen_max_laenge - name.length)
      puts "  #{name}:#{padding} #{wert}"
    end
  end
end
