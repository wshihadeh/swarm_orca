# frozen_string_literal: true

require 'swarm_orca/version'

module Capistrano
  # SwarmOrca
  module SwarmOrca
    require 'capistrano/swarm_orca/helpers/fetch_config'
    require 'capistrano/swarm_orca/local'
  end
end
