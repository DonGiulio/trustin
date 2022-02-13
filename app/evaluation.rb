# frozen_string_literal: true

class Evaluation
  attr_accessor :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def favorable?
    state == 'favorable'
  end

  def unfavorable?
    state == 'unfavorable'
  end

  def unconfirmed?
    state == 'unconfirmed'
  end

  def to_s
    "#{@type}, #{@value}, #{@score}, #{@state}, #{@reason}"
  end
end
