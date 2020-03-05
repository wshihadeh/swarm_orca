# frozen_string_literal: true

require_relative 'lib/swarm_orca/version'

Gem::Specification.new do |gem|
  gem.name        = 'swarm_orca'
  gem.version     = SwarmOrca::VERSION
  gem.summary     = 'Swarm Orca'
  gem.description = 'Orcastraction tool for rails application on swarm with capistrano'
  gem.authors     = ['Al-waleed Shiahdeh']
  gem.email       = 'wshihadh@gmail'
  gem.homepage    = 'https://github.com/wshihadeh/swarm_orca'

  gem.files         = `git ls-files`.split("\n")
  gem.bindir        = 'bin'
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.13'
  gem.add_development_dependency 'overcommit', '~> 0.47.0'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rubocop', '~> 0.66.0'

  gem.add_dependency 'capistrano', '~>  3.2'
  gem.add_dependency 'thor'
end
