# frozen_string_literal: true

require './app/evaluators/common_evaluator'

class SirenEvaluator < CommonEvaluator
  def type
    'SIREN'
  end

  def evaluate
    if evaluation_required?
      open_data_soft
      return
    end

    if @evaluation.unconfirmed? &&
       @evaluation.reason == 'unable_to_reach_api'
      if @evaluation.score >= 50
        update_score(-5)
      elsif @evaluation.score.positive? && @evaluation.score < 50
        update_score(-1)
      end
      return
    end

    return if @evaluation.unfavorable?

    update_score(-1) if @evaluation.favorable?
  end

  private

  def open_data_soft
    parsed_response = open_data_soft_info(@evaluation.value)
    company_state = parsed_response['records'].first['fields']['etatadministratifetablissement']

    if company_state == 'Actif'
      @evaluation.state = 'favorable'
      @evaluation.reason = 'company_opened'
      @evaluation.score = 100
    else
      @evaluation.state = 'unfavorable'
      @evaluation.reason = 'company_closed'
      # TBD score 100 for a closed unfavorable company?
      @evaluation.score = 100
    end
  end

  def open_data_soft_info(value)
    uri = URI('https://public.opendatasoft.com/api/records/1.0/search/' \
            '?dataset=sirene_v3' \
            "&q=#{value}" \
            '&sort=datederniertraitementetablissement' \
            '&refine.etablissementsiege=oui')
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
