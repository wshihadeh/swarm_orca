# frozen_string_literal: true

require 'thor'
require_relative 'new'
require_relative 'encrypt'
module SwarmOrca
  module Cli
    # Orca command line class
    class OrcaCli < Thor
      desc 'new ORCA_DIRECTORY_NAME GIT_FORK DOCKER_NETWORK',
           'This Command will create a new Orca project'
      long_desc <<-ORCA_NEW
        ORCA_DIRECTORY_NAME: Name of the root directory of orca.\n
        GIT_FORK: Orca github fork.\n
        DOCKER_NETWORK: Docker swarm newtwork name.
      ORCA_NEW

      def new(orca_directory_name, git_fork, docker_network)
        New.new(root_dir: Dir.pwd,
                orca_directory_name: orca_directory_name,
                git_fork: git_fork,
                docker_network: docker_network).execute
      end

      desc 'gen_enc_key', 'This Command will generate new encryption key'
      def gen_enc_key
        say("Encryption Key: #{Encrypt.generate_key}")
      end

      desc 'encrypt KEY TEXT', 'This Command will encrypt the given text'
      def encrypt(key, text)
        say(Encrypt.new(key).encrypt(text).to_s)
      end

      desc 'decrypt KEY CIPHER', 'This Command will decrypt the given cipher'
      def decrypt(key, cipher)
        say(Encrypt.new(key).decrypt(cipher).to_s)
      end
    end
  end
end
