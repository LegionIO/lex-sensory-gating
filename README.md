# lex-sensory-gating

Pre-attentive stimulus filtering for LegionIO cognitive agents. Controls which incoming stimuli pass through to higher cognitive processing based on modality-specific gate thresholds.

## What It Does

`lex-sensory-gating` maintains a set of modality-specific filters. Each filter has a gate threshold — stimuli with intensity above the threshold pass; those below are blocked. Filters habituate over time (threshold rises under repeated stimulus load) and can be sensitized on demand (threshold drops for important modalities).

- **Modalities**: `:visual`, `:auditory`, `:textual`, `:semantic`, `:emotional`, `:temporal`, `:social`
- **Effective threshold**: `gate_threshold + habituation_level` — habituation is additive
- **Habituation**: threshold rises automatically with each processed stimulus (background noise suppression)
- **Sensitization**: threshold drops on demand (attention shift resets suppression)
- **Pass rate tracking**: each filter records total passed vs blocked counts

## Usage

```ruby
require 'legion/extensions/sensory_gating'

client = Legion::Extensions::SensoryGating::Client.new

# Create a filter for a modality
result = client.create_filter(modality: :textual)
filter_id = result[:filter_id]

# Process a stimulus
client.process_stimulus(filter_id: filter_id, intensity: 0.7)
# => { result: :passed, intensity: 0.7, threshold: 0.5 }

client.process_stimulus(filter_id: filter_id, intensity: 0.3)
# => { result: :blocked, intensity: 0.3, threshold: 0.52 }
# (threshold rose due to habituation from the previous stimulus)

# Sensitize after something important happens
client.sensitize(filter_id: filter_id)
# => { success: true, filter_id: ..., habituation_level: 0.0 }

# Manually adjust gate
client.open_gate(filter_id: filter_id)   # lower threshold by 0.05
client.close_gate(filter_id: filter_id)  # raise threshold by 0.05

# Check average pass rate across all filters
client.average_pass_rate
# => { success: true, average_pass_rate: 0.68 }

# Full gating report
client.gating_report
# => { filter_count:, average_pass_rate:, most_restrictive: [...], most_permissive: [...] }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
