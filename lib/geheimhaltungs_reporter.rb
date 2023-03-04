# frozen_string_literal: true

require 'weiterleitungs_reporter'

# Reporter, der fast alles weiterleitet. Sachen, die Spieler nicht wissen,
# i.e. Handkarten anderer Spieler, werden nicht weitergeleitet.
class GeheimhaltungsReporter < WeiterleitungsReporter
  def berichte_start_situation(karten:, auftraege:)
    super(karten: karten.map { [] }, auftraege: auftraege)
  end
end
