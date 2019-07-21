# frozen_string_literal: true

require 'openssl'
require 'base64'

module SwarmOrca
  module Cli
    # Orca encrypt class
    class Encrypt
      CIPHER = 'aes-256-cbc'
      IV     = '2adae58101d71b14cbfa3bdaf17d26c8'

      def initialize(key)
        @key = key
      end

      def self.generate_key
        SecureRandom.hex(32)
      end

      def encrypt(clear_text)
        cipher = OpenSSL::Cipher.new(CIPHER)
        cipher.encrypt
        cipher.key  = [@key].pack('H*')
        cipher.iv   = [IV].pack('H*')
        cipher_text = cipher.update(clear_text) + cipher.final
        Base64.encode64(cipher_text).tr("\n", '')
      end

      def decrypt(encoded_text)
        cipher_text = Base64.decode64(encoded_text)
        cipher = OpenSSL::Cipher.new(CIPHER)
        cipher.decrypt
        cipher.key  = [@key].pack('H*')
        cipher.iv   = [IV].pack('H*')
        cipher.update(cipher_text) + cipher.final
      end
    end
  end
end
