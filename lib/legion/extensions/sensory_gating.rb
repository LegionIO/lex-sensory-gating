# frozen_string_literal: true

require_relative 'sensory_gating/version'
require_relative 'sensory_gating/helpers/constants'
require_relative 'sensory_gating/helpers/sensory_filter'
require_relative 'sensory_gating/helpers/gating_engine'
require_relative 'sensory_gating/runners/sensory_gating'
require_relative 'sensory_gating/client'

module Legion
  module Extensions
    module SensoryGating
    end
  end
end
