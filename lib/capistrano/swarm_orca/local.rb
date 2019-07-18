# frozen_string_literal: true

require 'rake'
require 'sshkit'
require 'capistrano/dsl'

module Capistrano
  # Capistrano Local
  module Local
  end
end

module Capistrano
  # Capistrano DSL
  module DSL
    alias original_on on

    def on(hosts, options = {}, &block)
      return unless hosts

      localhosts, remotehosts = Array(hosts).partition { |h| h.hostname.to_s =~ /local|127.0.0.1/ }
      localhost = Configuration.env.filter(localhosts).first

      ssh_backend.new(localhost, &block).run unless localhost.nil?

      original_on(remotehosts, options, &block)
    end

    private

    def ssh_backend
      if dry_run?
        SSHKit::Backend::Printer
      else
        SSHKit::Backend::Local
      end
    end

    def dry_run?
      fetch(:sshkit_backend) == SSHKit::Backend::Printer
    end
  end
end
