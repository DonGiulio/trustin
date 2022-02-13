# frozen_string_literal: true

class VatEvaluator < CommonEvaluator
  def type
    'VAT'
  end

  def evaluate
    if evaluation_required?
      check_evaluation
      return
    end

    if @evaluation.unconfirmed? &&
       @evaluation.reason == 'unable_to_reach_api'

      if @evaluation.score >= 50
        update_score(-1)
      elsif @evaluation.score.positive? && @evaluation.score < 50
        update_score(-3)
      end
      return
    end

    return if @evaluation.unfavorable?

    update_score(-1) if @evaluation.favorable?
  end

  private

  def check_evaluation
    data = [
      { state: 'favorable', reason: 'company_opened' },
      { state: 'unfavorable', reason: 'company_closed' },
      { state: 'unconfirmed', reason: 'unable_to_reach_api' },
      { state: 'unconfirmed', reason: 'ongoing_database_update' }
    ].sample
    @evaluation.state = data[:state]
    @evaluation.reason = data[:reason]
    @evaluation.score = 100
  end
end
