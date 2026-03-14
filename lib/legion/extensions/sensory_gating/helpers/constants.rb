# frozen_string_literal: true

module Legion
  module Extensions
    module SensoryGating
      module Helpers
        module Constants
          MAX_STIMULI = 500
          MAX_FILTERS = 100

          DEFAULT_GATE_THRESHOLD = 0.5
          GATE_ADJUSTMENT = 0.05
          HABITUATION_RATE = 0.02
          SENSITIZATION_RATE = 0.08

          GATE_LABELS = {
            (0.8..)     => :wide_open,
            (0.6...0.8) => :permissive,
            (0.4...0.6) => :selective,
            (0.2...0.4) => :restrictive,
            (..0.2)     => :blocked
          }.freeze

          STIMULUS_LABELS = {
            (0.8..)     => :overwhelming,
            (0.6...0.8) => :strong,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :mild,
            (..0.2)     => :subliminal
          }.freeze

          MODALITY_TYPES = %i[
            visual auditory textual semantic
            emotional temporal social
          ].freeze
        end
      end
    end
  end
end
