# frozen_string_literal: true

module Capistrano
  # SwarmOrca helpers
  module SwarmOrca
    def stacks
      fetch(:service_stacks) + fetch(:service_stacks_with_build_image) + application_stacks
    end

    def all_service_stacks
      fetch(:service_stacks) + fetch(:service_stacks_with_build_image)
    end

    def db_apps
      fetch(:db_apps_stacks_mapping, {}).values.flatten
    end

    def elasticsearch_apps
      fetch(:elasticsearch_apps)
    end

    def docker_command
      "#{fetch(:docker_path)}docker"
    end

    def application_stacks
      fetch(:db_apps_stacks_mapping, {}).keys.map(&:to_s)
    end

    def service_stacks_with_build_image
      fetch(:service_stacks_with_build_image)
    end

    def fetch_config(stack, env_var)
      fetch_application_config(stack)[env_var.to_sym] || ''
    end

    def fetch_application_config(stack)
      included_shared_config = fetch(stack.to_s.to_sym).fetch(:include_shared_config, '')
      config = fetch(:shared, {}).merge(fetch(included_shared_config.to_sym, {})).merge(fetch(stack.to_s.to_sym, {}))
      config.merge(orca_network: fetch(:network))
    end

    def fetch_stack_db_apps(stack)
      fetch(:db_apps_stacks_mapping, {})[stack.to_sym] || []
    end

    def env_vars_command_for_docker(stack)
      decrypt_env(stack).map { |k, _v| "-e #{k.to_s.upcase}=\"$#{k.to_s.upcase}\"" }.join(' ')
    end

    def env_vars_command(stack)
      export_lines = decrypt_env(stack).map { |k, v| "export #{k.to_s.upcase}=#{v}" }.join(';')
      encrypted_vars?(stack) ? "#{load_encrypt_lib};#{export_lines}" : export_lines
    end

    def erb_vars_command(stack)
      decrypt_env(stack).map { |k, _v| "#{k.to_s.upcase}='$#{k.to_s.upcase}'" }.join(';')
    end

    def load_encrypt_lib
      File.read("#{bash_source_root}/crypt").strip
    end

    def encrypted_vars?(stack)
      !fetch_application_config(stack).select { |k, _| encrypted?(k) }.empty?
    end

    def decrypt_env(stack)
      encrypted_vars = fetch_application_config(stack).select { |k, _| encrypted?(k) }
      unencrypted_vars = fetch_application_config(stack).reject { |k, _| encrypted?(k) }
      unencrypted_vars.transform_values! { |v| Shellwords.escape(v) }
      configs = unencrypted_vars.merge(encrypted_vars.transform_values { |v| decrypt_var(v) })
      configs.transform_keys { |k| k.to_s.sub(/^#{encrypted_prefix}/, '') }
    end

    def decrypt_var(var)
      "$(decrypt '#{var}')"
    end

    def docker_erb_templates
      fetch(:docker_erb_templates)
    end

    def docker_cleanup
      fetch(:docker_cleanup)
    end

    def build_docker_images
      fetch(:auto_image_build)
    end

    def encrypted_prefix
      'encrypted_'
    end

    def encrypted?(key)
      key.to_s.start_with?(encrypted_prefix)
    end

    def bash_source_root
      "#{File.dirname(__FILE__)}/../bash"
    end

    def upload_script(shell_command, description)
      filename = capture("mktemp /tmp/#{script_prefix}#{description}_XXXXXXX")
      upload! StringIO.new(shell_command), filename
      filename
    end

    def script_prefix
      'ORCA_SSH_SCRIPT_'
    end

    def debug_mode?
      %(true yes 1).include? ENV.fetch('ORCA_DEBUG', 'false')
    end

    def show_debug_messages(host, shell_command, description)
      $stdout.puts <<~MESSAGE

        \e[33mExecuting: #{description} ON #{host}
        Bash Script:\n#{shell_command}\e[0m
      MESSAGE
    end

    def execute_orca_script(host, shell_command, description)
      show_debug_messages(host, shell_command, description) if debug_mode?
      with ENCRYPTION_KEY: ENV.fetch('ENCRYPTION_KEY', nil) do
        execute :bash, upload_script(shell_command, description)
      end
      execute :rm, "/tmp/#{script_prefix}*"
    end
  end
end
