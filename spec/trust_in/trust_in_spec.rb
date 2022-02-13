# frozen_string_literal: true

require './app/trust_in'

RSpec.describe TrustIn do
  describe '#update_score()' do
    context 'correct' do
      subject! { described_class.new(evaluations).update_score }

      context 'with SIREN' do
        let(:evaluations) do
          [Evaluation.new(type: 'SIREN',
                          value: '123456789',
                          score: 79,
                          state: 'unconfirmed',
                          reason: 'unable_to_reach_api')]
        end

        it 'changed evaluation' do
          expect(evaluations.first.score).to eq(74)
        end
      end

      context 'with VAT' do
        let(:evaluations) do
          [Evaluation.new(type: 'VAT',
                          value: '123456789',
                          score: 79,
                          state: 'unconfirmed',
                          reason: 'unable_to_reach_api')]
        end

        it 'changed evaluation' do
          expect(evaluations.first.score).to eq(78)
        end
      end
    end

    context 'with exception' do
      context 'with unknown' do
        let(:evaluations) do
          [Evaluation.new(type: 'OTHER',
                          value: '123456789',
                          score: 79,
                          state: 'unconfirmed',
                          reason: 'unable_to_reach_api')]
        end
        it 'changed evaluation' do
          expect { described_class.new(evaluations).update_score }.to raise_error 'unknown type'
        end
      end
    end
  end
end
