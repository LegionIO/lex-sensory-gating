# frozen_string_literal: true

RSpec.describe Legion::Extensions::SensoryGating::Helpers::SensoryFilter do
  subject(:filter) { described_class.new(modality: :visual) }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(filter.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets modality' do
      expect(filter.modality).to eq(:visual)
    end

    it 'defaults gate_threshold' do
      default = Legion::Extensions::SensoryGating::Helpers::Constants::DEFAULT_GATE_THRESHOLD
      expect(filter.gate_threshold).to eq(default)
    end

    it 'starts with 0 habituation' do
      expect(filter.habituation_level).to eq(0.0)
    end

    it 'starts with 0 passed and blocked' do
      expect(filter.stimuli_passed).to eq(0)
      expect(filter.stimuli_blocked).to eq(0)
    end
  end

  describe '#process' do
    it 'passes high-intensity stimuli' do
      expect(filter.process(intensity: 0.9)).to eq(:passed)
      expect(filter.stimuli_passed).to eq(1)
    end

    it 'blocks low-intensity stimuli' do
      expect(filter.process(intensity: 0.1)).to eq(:blocked)
      expect(filter.stimuli_blocked).to eq(1)
    end

    it 'habituates after passing stimuli' do
      filter.process(intensity: 0.9)
      expect(filter.habituation_level).to be > 0.0
    end
  end

  describe '#open_gate!' do
    it 'decreases gate threshold' do
      original = filter.gate_threshold
      filter.open_gate!
      expect(filter.gate_threshold).to be < original
    end

    it 'clamps at 0.0' do
      f = described_class.new(modality: :visual, gate_threshold: 0.01)
      f.open_gate!(amount: 0.5)
      expect(f.gate_threshold).to eq(0.0)
    end
  end

  describe '#close_gate!' do
    it 'increases gate threshold' do
      original = filter.gate_threshold
      filter.close_gate!
      expect(filter.gate_threshold).to be > original
    end
  end

  describe '#sensitize!' do
    it 'decreases habituation level' do
      filter.process(intensity: 0.9)
      hab = filter.habituation_level
      filter.sensitize!
      expect(filter.habituation_level).to be < hab
    end
  end

  describe '#reset_habituation!' do
    it 'resets habituation to 0' do
      filter.process(intensity: 0.9)
      filter.reset_habituation!
      expect(filter.habituation_level).to eq(0.0)
    end
  end

  describe '#effective_threshold' do
    it 'combines gate_threshold and habituation' do
      filter.process(intensity: 0.9)
      expect(filter.effective_threshold).to be > filter.gate_threshold
    end
  end

  describe '#pass_rate' do
    it 'returns 0.0 with no stimuli' do
      expect(filter.pass_rate).to eq(0.0)
    end

    it 'calculates ratio' do
      filter.process(intensity: 0.9)
      filter.process(intensity: 0.1)
      expect(filter.pass_rate).to eq(0.5)
    end
  end

  describe '#gate_label' do
    it 'returns a symbol' do
      expect(filter.gate_label).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = filter.to_h
      expect(hash).to include(
        :id, :modality, :gate_threshold, :effective_threshold,
        :habituation_level, :gate_label, :stimuli_passed,
        :stimuli_blocked, :pass_rate, :created_at
      )
    end
  end
end
