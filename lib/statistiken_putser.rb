# frozen_string_literal: true

# Hilfsmodul für Reporter um Statistiken auszugeben.
module StatistikenPutser
  def berichte_statistiken(statistiken_name, statistiken)
    return if statistiken.empty?

    puts "#{statistiken_name} Statistiken:"
    namen_max_laenge = statistiken.keys.map(&:length).max
    stat_stuff = statistiken.map do |name, wert|
      namen_padding = ' ' * (namen_max_laenge - name.length)
      wert_padding = wert < 0.1 ? ' ' : ''
      "  #{name}:#{namen_padding} #{wert_padding}#{(wert*100).round(2)}%"
    end
    puts stat_stuff.sort!
  end
end
