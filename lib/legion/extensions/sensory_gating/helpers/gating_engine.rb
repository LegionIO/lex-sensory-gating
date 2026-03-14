# frozen_string_literal: true

module Legion
  module Extensions
    module SensoryGating
      module Helpers
        class GatingEngine
          include Constants

          def initialize
            @filters = {}
          end

          def create_filter(modality:, gate_threshold: DEFAULT_GATE_THRESHOLD)
            prune_if_needed
            filter = SensoryFilter.new(modality: modality, gate_threshold: gate_threshold)
            @filters[filter.id] = filter
            filter
          end

          def process_stimulus(filter_id:, intensity:)
            filter = @filters[filter_id]
            return nil unless filter

            outcome = filter.process(intensity: intensity)
            { outcome: outcome, filter: filter }
          end

          def open_gate(filter_id:, amount: GATE_ADJUSTMENT)
            filter = @filters[filter_id]
            return nil unless filter

            filter.open_gate!(amount: amount)
          end

          def close_gate(filter_id:, amount: GATE_ADJUSTMENT)
            filter = @filters[filter_id]
            return nil unless filter

            filter.close_gate!(amount: amount)
          end

          def sensitize(filter_id:, amount: SENSITIZATION_RATE)
            filter = @filters[filter_id]
            return nil unless filter

            filter.sensitize!(amount: amount)
          end

          def reset_habituation(filter_id:)
            filter = @filters[filter_id]
            return nil unless filter

            filter.reset_habituation!
          end

          def filters_by_modality(modality:)
            m = modality.to_sym
            @filters.values.select { |f| f.modality == m }
          end

          def average_pass_rate
            return 0.0 if @filters.empty?

            rates = @filters.values.map(&:pass_rate)
            (rates.sum / rates.size).round(10)
          end

          def most_restrictive(limit: 5)
            @filters.values.sort_by(&:effective_threshold).reverse.first(limit)
          end

          def most_permissive(limit: 5)
            @filters.values.sort_by(&:effective_threshold).first(limit)
          end

          def gating_report
            {
              total_filters:     @filters.size,
              average_pass_rate: average_pass_rate,
              most_restrictive:  most_restrictive(limit: 3).map(&:to_h),
              most_permissive:   most_permissive(limit: 3).map(&:to_h)
            }
          end

          def to_h
            {
              total_filters:     @filters.size,
              average_pass_rate: average_pass_rate
            }
          end

          private

          def prune_if_needed
            return if @filters.size < MAX_FILTERS

            oldest = @filters.values.min_by(&:created_at)
            @filters.delete(oldest.id) if oldest
          end
        end
      end
    end
  end
end
