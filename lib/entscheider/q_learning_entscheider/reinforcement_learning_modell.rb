class ReinforcementLearningModell
  def bewerte(ai_input)
    raise NotImplementedError
  end

  def merke(ai_input, bewertung, alter_ai_input, ai_aktionen)
    raise NotImplementedError
  end
end
