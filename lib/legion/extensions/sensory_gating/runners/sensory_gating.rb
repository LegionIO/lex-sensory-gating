# frozen_string_literal: true

module Legion
  module Extensions
    module SensoryGating
      module Runners
        module SensoryGating
          include Helpers::Constants

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_filter(modality:, engine: nil, gate_threshold: DEFAULT_GATE_THRESHOLD, **)
            eng = engine || default_engine
            filter = eng.create_filter(modality: modality, gate_threshold: gate_threshold)
            { success: true, filter: filter.to_h }
          end

          def process_stimulus(filter_id:, intensity:, engine: nil, **)
            eng = engine || default_engine
            result = eng.process_stimulus(filter_id: filter_id, intensity: intensity)
            return { success: false, error: 'filter not found' } unless result

            { success: true, outcome: result[:outcome], filter: result[:filter].to_h }
          end

          def open_gate(filter_id:, engine: nil, amount: GATE_ADJUSTMENT, **)
            eng = engine || default_engine
            result = eng.open_gate(filter_id: filter_id, amount: amount)
            return { success: false, error: 'filter not found' } unless result

            { success: true, filter: result.to_h }
          end

          def close_gate(filter_id:, engine: nil, amount: GATE_ADJUSTMENT, **)
            eng = engine || default_engine
            result = eng.close_gate(filter_id: filter_id, amount: amount)
            return { success: false, error: 'filter not found' } unless result

            { success: true, filter: result.to_h }
          end

          def sensitize(filter_id:, engine: nil, amount: SENSITIZATION_RATE, **)
            eng = engine || default_engine
            result = eng.sensitize(filter_id: filter_id, amount: amount)
            return { success: false, error: 'filter not found' } unless result

            { success: true, filter: result.to_h }
          end

          def average_pass_rate(engine: nil, **)
            eng = engine || default_engine
            { success: true, pass_rate: eng.average_pass_rate }
          end

          def gating_report(engine: nil, **)
            eng = engine || default_engine
            { success: true, report: eng.gating_report }
          end

          private

          def default_engine
            @default_engine ||= Helpers::GatingEngine.new
          end
        end
      end
    end
  end
end
