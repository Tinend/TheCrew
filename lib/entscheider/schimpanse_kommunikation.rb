# coding: utf-8
# frozen_string_literal: true

# Zum Sortieren von Kommunikation für den Schimpansen
class SchimpanseKommunikation
  def initialize(kommunikation:, prioritaet:)
    @kommunikation = kommunikation
    @prioritaet = prioritaet
  end

  attr_reader :kommunikation, :prioritaet

  def verbessere(schimpansen_kommunikation)
    return unless @prioritaet < schimpansen_kommunikation.prioritaet

    @prioritaet = schimpansen_kommunikation.prioritaet
    @kommunikation = schimpansen_kommunikation.kommunikation
  end
end
