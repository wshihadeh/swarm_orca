# frozen_string_literal: true

module SwarmOrca
  module Cli
    # Orca new command class
    class New
      include Thor::Base
      include Thor::Actions
      source_root "#{File.dirname(__FILE__)}/templates/orca"

      def initialize(root_dir:, orca_dir_name: 'orca', git_fork: nil, network: 'default_network')
        self.destination_root = "#{root_dir}/#{orca_dir_name}"
        @options = { pretend: false }
        self.behavior = :invoke
        @orca_directory_name = orca_dir_name
        @orca_version = SwarmOrca::VERSION
        @git_fork = git_fork
        @docker_network = network
        @gemset = "orca_#{git_fork}_#{network}"
      end

      # rubocop:disable Metrics/MethodLength
      def execute
        say('Start Generating orca files')
        %w[
          .gitignore
          .ruby-version
          README.md
          capistrano/Capfile
          nginx/Dockerfile
          nginx/nginx.conf
          redis/Dockerfile
          redis/redis.conf
          capistrano/config/deploy/template_stage.rb
        ].each do |file|
          copy_file "#{source_root}/#{file}", "#{destination_root}/#{file}"
        end

        %w[
          capistrano/Gemfile
          .ruby-gemset
          capistrano/config/deploy.rb
          application_stack/docker-stack-elasticsearch.yml.erb
          application_stack/docker-stack-errbit.yml.erb
          application_stack/docker-stack-mysql.yml.erb
          application_stack/docker-stack-nginx.yml.erb
          application_stack/docker-stack-rabbitmq.yml.erb
          application_stack/docker-stack-redis.yml.erb
        ].each do |file|
          template "#{source_root}/#{file}.tt", "#{destination_root}/#{file}"
        end

        say('Complete!', :green)
        say('Next step is to create development stage file from the', :green)
        say(' template file use the following commands to do it', :green)
        say("cd #{destination_root}/capistrano", :green)
        say('gem install bundler', :green)
        say('bundle install', :green)
        say("cd #{destination_root}/capistrano/config/deploy", :green)
        say('cp template_stage.rb development.rb', :green)
        say('Replace all ${VAR} with a valid value', :green)
        say('Read Readme for more information', :green)
      end
      # rubocop:enable Metrics/MethodLength

      private

      def source_root
        self.class.source_root
      end
    end
  end
end
