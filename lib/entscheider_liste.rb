# frozen_string_literal: true

require 'entscheider/zufalls_entscheider'
require 'entscheider/hase'
require 'entscheider/saeuger'
require 'entscheider/archaeon'
require 'entscheider/rhinoceros'
require 'entscheider/reinwerfer'
require 'entscheider/geschlossene_formel_bot'
require 'entscheider/schimpanse'

# Liste aller Entscheider.
module EntscheiderListe
  def self.entscheider_klassen
    @entscheider_klassen ||= [Schimpanse, Reinwerfer, Rhinoceros, Hase, Saeuger, Archaeon, ZufallsEntscheider,
                              GeschlosseneFormelBot].freeze
  end
end
