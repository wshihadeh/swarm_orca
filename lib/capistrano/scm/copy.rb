# frozen_string_literal: true

require 'capistrano/scm/plugin'
require 'cgi'
require 'shellwords'
require 'uri'
require_relative 'tasks/deploy.rb'

module Capistrano
  class SCM
    # Capistrano Copy stretegy
    class Copy < Capistrano::SCM::Plugin
      def set_defaults
        set_if_empty :app_release_id, Time.now.to_i
        set_if_empty :tar_extension, '.tar.gz'
        set_if_empty :app_source_file_path, "/tmp/s_#{fetch(:app_release_id)}#{fetch(:tar_extension)}"
        set_if_empty :app_destination_file_path, "/tmp/#{fetch(:app_release_id)}#{fetch(:tar_extension)}"
      end

      def working_dir
        File.dirname(Dir.pwd)
      end

      def register_hooks
        after 'deploy:new_release_path', 'copy:create_release'
        before 'deploy:set_current_revision', 'copy:set_current_revision'
      end

      def define_tasks
        eval_rakefile File.expand_path('tasks/copy.cap', __dir__)
      end

      def tar_exists?
        backend.test " [ -f #{fetch(:app_destination_file_path)} ] "
      end

      def create_tar
        source_path = Shellwords.escape(working_dir)
        run_locally do
          execute "tar -C #{source_path} -czf #{fetch(:app_source_file_path)} ."
        end
      end

      def remove_tar
        run_locally do
          execute "rm -f #{fetch(:app_source_file_path)}"
        end
      end

      def archive_to_release_path
        # Unpack the tar uploaded by deploy:upload_tar task.
        backend.execute "tar -xzmf #{fetch(:app_destination_file_path)} -C #{release_path}"
        # Remove it just to keep things clean.
        backend.execute :rm, fetch(:app_destination_file_path)
      end

      def fetch_revision
        fetch(:app_release_id)
      end
    end
  end
end
