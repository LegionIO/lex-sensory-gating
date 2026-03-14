# frozen_string_literal: true

require_relative 'lib/legion/extensions/sensory_gating/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-sensory-gating'
  spec.version       = Legion::Extensions::SensoryGating::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Sensory gating and stimulus filtering for LegionIO'
  spec.description   = 'Models sensory filtering with habituation, sensitization, and gate control'
  spec.homepage      = 'https://github.com/LegionIO/lex-sensory-gating'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = spec.homepage
  spec.metadata['documentation_uri']   = "#{spec.homepage}/blob/main/README.md"
  spec.metadata['changelog_uri']       = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']     = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
