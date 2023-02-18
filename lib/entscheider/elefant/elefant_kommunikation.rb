# coding: utf-8
# frozen_string_literal: true

# Zum Sortieren von Kommunikation für den Elefanten
class ElefantKommunikation
  def initialize(kommunikation:, prioritaet:)
    @kommunikation = kommunikation
    @prioritaet = prioritaet
  end

  attr_reader :kommunikation, :prioritaet

  def verbessere(elefant_kommunikation)
    return unless @prioritaet < elefant_kommunikation.prioritaet

    @prioritaet = elefant_kommunikation.prioritaet
    @kommunikation = elefant_kommunikation.kommunikation
  end
end
