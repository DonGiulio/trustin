# frozen_string_literal: true

require './app/trust_in'

# TODO: remote api calls need to be stubbed in tests
RSpec.describe SirenEvaluator do
  let(:type) { 'SIREN' }
  subject! { described_class.new(evaluation).evaluate }

  context "with a <score> greater or equal to 50 AND the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
    let(:evaluation) do
      Evaluation.new(type: type,
                     value: '123456789',
                     score: 79,
                     state: 'unconfirmed',
                     reason: 'unable_to_reach_api')
    end

    it 'decreases the <score> of 5' do
      expect(evaluation.score).to eq(74)
    end
  end

  context "with a <score> equal to 50 AND the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
    let(:evaluation) do
      Evaluation.new(type: type,
                     value: '123456789',
                     score: 50,
                     state: 'unconfirmed',
                     reason: 'unable_to_reach_api')
    end

    it 'decreases the <score> of 5' do
      expect(evaluation.score).to eq(45)
    end
  end

  context "when the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
    let(:evaluation) do
      Evaluation.new(type: type,
                     value: '123456789',
                     score: 37,
                     state: 'unconfirmed',
                     reason: 'unable_to_reach_api')
    end

    it 'decreases the <score> of 1' do
      expect(evaluation.score).to eq(36)
    end
  end

  context 'when the <state> is favorable' do
    let(:evaluation) do
      Evaluation.new(type: type,
                     value: '123456789',
                     score: 28,
                     state: 'favorable',
                     reason: 'company_opened')
    end

    it 'decreases the <score> of 1' do
      expect(evaluation.score).to eq(27)
    end
  end

  describe 'based on the API response' do
    context "when the <state> is 'unconfirmed' AND the <reason> is 'ongoing_database_update'" do
      let(:evaluation) do
        Evaluation.new(type: type,
                       value: '832940670',
                       score: 42,
                       state: 'unconfirmed',
                       reason: 'ongoing_database_update')
      end

      it 'assigns a <state> and a <reason> to the evaluation and a <score> to 100' do
        expect(evaluation.state).to eq('favorable')
        expect(evaluation.reason).to eq('company_opened')
        expect(evaluation.score).to eq(100)
      end
    end

    context 'with a <score> equal to 0' do
      let(:evaluation) do
        Evaluation.new(type: type,
                       value: '320878499',
                       score: 0,
                       state: 'favorable',
                       reason: 'company_opened')
      end

      it 'assigns a <state> and a <reason> to the evaluation and a <score> to 100' do
        expect(evaluation.state).to eq('unfavorable')
        expect(evaluation.reason).to eq('company_closed')
        expect(evaluation.score).to eq(100)
      end
    end
  end

  context "with a <state> 'unfavorable'" do
    let(:evaluation) do
      Evaluation.new(type: type,
                     value: '123456789',
                     score: 52,
                     state: 'unfavorable',
                     reason: 'company_closed')
    end

    it 'does not decrease its <score>' do
      expect { subject }.not_to change { evaluation.score }
    end
  end

  context "with a <state>'unfavorable' AND a <score> equal to 0" do
    let(:evaluation) do
      Evaluation.new(type: type,
                     value: '123456789',
                     score: 0,
                     state: 'unfavorable',
                     reason: 'company_closed')
    end

    it 'does not call the API' do
      expect(Net::HTTP).not_to receive(:get)
    end
  end
end
