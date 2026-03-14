# lex-sensory-gating

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-sensory-gating`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::SensoryGating`

## Purpose

Controls which stimuli pass through to higher cognitive processing. Each modality (visual, auditory, textual, semantic, emotional, temporal, social) has a filter with a configurable gate threshold. Stimuli above the threshold pass; those below are blocked. Filters habituate (threshold rises on repeated exposure of the same modality) and can be sensitized (threshold drops on demand). Models the brain's pre-attentive suppression of irrelevant background stimuli.

## Gem Info

- **Gem name**: `lex-sensory-gating`
- **License**: MIT
- **Ruby**: >= 3.4
- **No runtime dependencies** beyond the Legion framework

## File Structure

```
lib/legion/extensions/sensory_gating/
  version.rb                         # VERSION = '0.1.0'
  helpers/
    constants.rb                     # thresholds, adjustment rates, labels, modality types
    sensory_filter.rb                # SensoryFilter class — per-modality gate with habituation
    gating_engine.rb                 # GatingEngine class — collection of filters with bulk operations
  runners/
    sensory_gating.rb                # Runners::SensoryGating module — all public runner methods
  client.rb                          # Client class including Runners::SensoryGating
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `MAX_STIMULI` | 500 | Maximum stimulus records stored |
| `MAX_FILTERS` | 100 | Maximum filters in the engine |
| `DEFAULT_GATE_THRESHOLD` | 0.5 | Base threshold for new filters |
| `GATE_ADJUSTMENT` | 0.05 | Amount threshold shifts on `open_gate!`/`close_gate!` |
| `HABITUATION_RATE` | 0.02 | Threshold increase per `process` call (habituation) |
| `SENSITIZATION_RATE` | 0.08 | Threshold decrease per `sensitize!` call |
| `GATE_LABELS` | hash | Named gate states based on effective_threshold |
| `STIMULUS_LABELS` | hash | Named stimulus strength categories |
| `MODALITY_TYPES` | 7 symbols | `:visual`, `:auditory`, `:textual`, `:semantic`, `:emotional`, `:temporal`, `:social` |

## Helpers

### `Helpers::SensoryFilter`

Per-modality gate with habituation state.

- `initialize(id:, modality:, gate_threshold: DEFAULT_GATE_THRESHOLD)` — habituation_level = 0.0, total_processed = 0, total_blocked = 0
- `effective_threshold` — `gate_threshold + habituation_level`
- `process(intensity)` — compares intensity against effective_threshold; if passed: increments total_processed, auto-habituates; if blocked: increments total_blocked; returns `{ result: :passed/:blocked, intensity:, threshold: }`
- `open_gate!` — decrements gate_threshold by GATE_ADJUSTMENT; floors at 0.0
- `close_gate!` — increments gate_threshold by GATE_ADJUSTMENT; caps at 1.0
- `sensitize!` — decrements habituation_level by SENSITIZATION_RATE; floors at 0.0
- `habituate!` — increments habituation_level by HABITUATION_RATE
- `reset_habituation!` — sets habituation_level = 0.0
- `pass_rate` — `total_processed.to_f / [total_processed + total_blocked, 1].max`

### `Helpers::GatingEngine`

Collection of SensoryFilter objects with bulk query operations.

- `initialize` — empty filters hash keyed by filter id
- `create_filter(modality:, gate_threshold: DEFAULT_GATE_THRESHOLD)` — returns nil if at MAX_FILTERS; reuses existing filter for a given modality if one exists
- `process_stimulus(filter_id:, intensity:)` — delegates to filter's `process`
- `open_gate(filter_id)` — calls `filter.open_gate!`
- `close_gate(filter_id)` — calls `filter.close_gate!`
- `sensitize(filter_id)` — calls `filter.sensitize!`
- `reset_habituation(filter_id)` — calls `filter.reset_habituation!`
- `filters_by_modality(modality)` — returns all filters for a given modality
- `average_pass_rate` — mean pass_rate across all filters
- `most_restrictive(limit: 5)` — sorted by effective_threshold descending
- `most_permissive(limit: 5)` — sorted by effective_threshold ascending
- `gating_report` — summary including filter count, average pass rate, most restrictive/permissive filters

## Runners

All runners are in `Runners::SensoryGating`. The `Client` includes this module and owns a `GatingEngine` instance.

| Runner | Parameters | Returns |
|---|---|---|
| `create_filter` | `modality:, gate_threshold: DEFAULT_GATE_THRESHOLD` | `{ success:, filter_id:, modality:, gate_threshold: }` |
| `process_stimulus` | `filter_id:, intensity:` | `{ success:, filter_id:, result:, intensity:, threshold: }` |
| `open_gate` | `filter_id:` | `{ success:, filter_id:, gate_threshold: }` |
| `close_gate` | `filter_id:` | `{ success:, filter_id:, gate_threshold: }` |
| `sensitize` | `filter_id:` | `{ success:, filter_id:, habituation_level: }` |
| `average_pass_rate` | (none) | `{ success:, average_pass_rate: }` |
| `gating_report` | (none) | Full `GatingEngine#gating_report` hash |

## Integration Points

- **lex-tick / lex-cortex**: `process_stimulus` can be wired to the `sensory_processing` phase; stimuli that pass are forwarded to downstream phases; blocked stimuli are discarded
- **lex-emotion**: emotional stimuli (`emotional` modality) should be gated before reaching the `emotional_evaluation` phase
- **lex-attention**: attention mechanisms can `open_gate!` for attended modalities and let remaining modalities habituate
- **lex-surprise**: unexpected events trigger `sensitize!` on the relevant modality filter (resets habituation, lowers threshold)
- **lex-mesh**: incoming mesh messages could be pre-filtered through a `social` modality gate before dispatch

## Development Notes

- `effective_threshold = gate_threshold + habituation_level` — habituation is additive on top of the base gate; sensitization reduces habituation_level only, not gate_threshold
- Auto-habituation on every `process` call means filters naturally become more restrictive under steady-state stimulus load
- `GATE_ADJUSTMENT = 0.05` and `SENSITIZATION_RATE = 0.08` — sensitization is faster than gate adjustment
- Multiple filters can share the same modality; `filters_by_modality` returns all of them
- `MAX_STIMULI = 500` is defined in constants but the current GatingEngine tracks pass/block counts on the filter objects rather than storing individual stimulus records
