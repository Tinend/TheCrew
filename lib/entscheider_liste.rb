# frozen_string_literal: true

require 'entscheider/zufalls_entscheider'
require 'entscheider/hase'
require 'entscheider/saeuger'
require 'entscheider/archaeon'
require 'entscheider/rhinoceros'
require 'entscheider/reinwerfer'
require 'entscheider/geschlossene_formel_bot'
require 'entscheider/schimpanse'
require 'entscheider/cowboy'
require 'entscheider/elefant'
require 'entscheider/bakterie'

# Liste aller Entscheider.
module EntscheiderListe
  def self.entscheider_klassen
    @entscheider_klassen ||= [Elefant, Cowboy, Schimpanse, Reinwerfer, Rhinoceros, Hase, Saeuger, Archaeon,
                              ZufallsEntscheider, GeschlosseneFormelBot, Bakterie].freeze
  end
end
