# frozen_string_literal: true

class CommonEvaluator
  def initialize(evaluation)
    unless evaluation.type == type
      raise "unknown evaluation type: #{evaluation.type}"
    end

    @evaluation = evaluation
  end

  def evaluation_required?
    return false if @evaluation.unfavorable?
    return true if @evaluation.unconfirmed? &&
                   @evaluation.reason == 'ongoing_database_update'
    return true if @evaluation.score.zero?

    false
  end

  def type
    raise 'unimplemented'
  end

  def update_score(value)
    @evaluation.score = @evaluation.score + value
    @evaluation.score = 0 if @evaluation.score.negative?
  end
end
