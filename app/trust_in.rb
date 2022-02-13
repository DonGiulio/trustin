# frozen_string_literal: true

require 'json'
require 'net/http'
require './app/evaluation'
require './app/evaluators/siren_evaluator'
require './app/evaluators/vat_evaluator'

class TrustIn
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_score
    @evaluations.each do |evaluation|
      case evaluation.type
      when 'SIREN'
        evaluate_with_siren(evaluation)
      when 'VAT'
        evaluate_with_vat(evaluation)
      else
        raise 'unknown type'
      end
    end
  end

  private

  def evaluate_with_siren(evaluation)
    SirenEvaluator.new(evaluation).evaluate
  end

  def evaluate_with_vat(evaluation)
    VatEvaluator.new(evaluation).evaluate
  end
end
