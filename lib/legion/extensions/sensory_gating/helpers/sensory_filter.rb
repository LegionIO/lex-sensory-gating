# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module SensoryGating
      module Helpers
        class SensoryFilter
          include Constants

          attr_reader :id, :modality, :gate_threshold, :habituation_level,
                      :stimuli_passed, :stimuli_blocked, :created_at

          def initialize(modality:, gate_threshold: DEFAULT_GATE_THRESHOLD)
            @id                = SecureRandom.uuid
            @modality          = modality.to_sym
            @gate_threshold    = gate_threshold.to_f.clamp(0.0, 1.0)
            @habituation_level = 0.0
            @stimuli_passed    = 0
            @stimuli_blocked   = 0
            @created_at        = Time.now.utc
          end

          def process(intensity:)
            effective_threshold = (@gate_threshold + @habituation_level).clamp(0.0, 1.0).round(10)
            if intensity >= effective_threshold
              @stimuli_passed += 1
              habituate!
              :passed
            else
              @stimuli_blocked += 1
              :blocked
            end
          end

          def open_gate!(amount: GATE_ADJUSTMENT)
            @gate_threshold = (@gate_threshold - amount).clamp(0.0, 1.0).round(10)
            self
          end

          def close_gate!(amount: GATE_ADJUSTMENT)
            @gate_threshold = (@gate_threshold + amount).clamp(0.0, 1.0).round(10)
            self
          end

          def sensitize!(amount: SENSITIZATION_RATE)
            @habituation_level = (@habituation_level - amount).clamp(-0.5, 0.5).round(10)
            self
          end

          def habituate!(amount: HABITUATION_RATE)
            @habituation_level = (@habituation_level + amount).clamp(-0.5, 0.5).round(10)
            self
          end

          def reset_habituation!
            @habituation_level = 0.0
            self
          end

          def effective_threshold
            (@gate_threshold + @habituation_level).clamp(0.0, 1.0).round(10)
          end

          def pass_rate
            total = @stimuli_passed + @stimuli_blocked
            return 0.0 if total.zero?

            (@stimuli_passed.to_f / total).round(4)
          end

          def gate_label
            match = GATE_LABELS.find { |range, _| range.cover?(@gate_threshold) }
            match ? match.last : :blocked
          end

          def to_h
            {
              id:                  @id,
              modality:            @modality,
              gate_threshold:      @gate_threshold,
              effective_threshold: effective_threshold,
              habituation_level:   @habituation_level,
              gate_label:          gate_label,
              stimuli_passed:      @stimuli_passed,
              stimuli_blocked:     @stimuli_blocked,
              pass_rate:           pass_rate,
              created_at:          @created_at
            }
          end
        end
      end
    end
  end
end
