# frozen_string_literal: true

RSpec.describe Legion::Extensions::SensoryGating::Runners::SensoryGating do
  let(:client) { Legion::Extensions::SensoryGating::Client.new }

  describe '#create_filter' do
    it 'returns success with filter hash' do
      result = client.create_filter(modality: :visual)
      expect(result[:success]).to be true
      expect(result[:filter]).to include(:id, :modality, :gate_threshold)
    end
  end

  describe '#process_stimulus' do
    it 'returns outcome' do
      f = client.create_filter(modality: :visual)
      result = client.process_stimulus(filter_id: f[:filter][:id], intensity: 0.9)
      expect(result[:success]).to be true
      expect(result[:outcome]).to eq(:passed)
    end

    it 'returns failure for unknown id' do
      result = client.process_stimulus(filter_id: 'fake', intensity: 0.5)
      expect(result[:success]).to be false
    end
  end

  describe '#open_gate' do
    it 'decreases threshold' do
      f = client.create_filter(modality: :visual)
      result = client.open_gate(filter_id: f[:filter][:id])
      expect(result[:success]).to be true
      expect(result[:filter][:gate_threshold]).to be < 0.5
    end
  end

  describe '#close_gate' do
    it 'increases threshold' do
      f = client.create_filter(modality: :visual)
      result = client.close_gate(filter_id: f[:filter][:id])
      expect(result[:success]).to be true
      expect(result[:filter][:gate_threshold]).to be > 0.5
    end
  end

  describe '#average_pass_rate' do
    it 'returns pass rate' do
      result = client.average_pass_rate
      expect(result[:success]).to be true
      expect(result[:pass_rate]).to be_a(Numeric)
    end
  end

  describe '#gating_report' do
    it 'returns a full report' do
      result = client.gating_report
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_filters, :average_pass_rate)
    end
  end
end
