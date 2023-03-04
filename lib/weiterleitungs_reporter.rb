# frozen_string_literal: true

require_relative 'tee_reporter'

# Leitet alles an einen anderen Reporter weiter.
class WeiterleitungsReporter < TeeReporter
  def initialize(reporter)
    super([reporter])
  end

  def reporter
    subreporter.first
  end
end
