require 'entscheider/zufalls_entscheider'
require 'entscheider/hase'
require 'entscheider/saeuger'
require 'entscheider/archaeon'
require 'entscheider/rhinoceros'
require 'entscheider/reinwerfer'
require 'entscheider/geschlossene_formel_bot'

module EntscheiderListe
  def self.entscheider_klassen
    ENTSCHEIDER_KLASSEN
  end

  private

  ENTSCHEIDER_KLASSEN = [Reinwerfer, Rhinoceros, Hase, Saeuger, Archaeon, ZufallsEntscheider, GeschlosseneFormelBot]
end
