# coding: utf-8
# frozen_string_literal: true

# Zum Sortieren von Kommunikation für den Bakterien
class BakterieKommunikation
  def initialize(kommunikation:, prioritaet:)
    @kommunikation = kommunikation
    @prioritaet = prioritaet
  end

  attr_reader :kommunikation, :prioritaet

  def verbessere(bakterien_kommunikation)
    return unless @prioritaet < bakterien_kommunikation.prioritaet

    @prioritaet = bakterien_kommunikation.prioritaet
    @kommunikation = bakterien_kommunikation.kommunikation
  end
end
