# frozen_string_literal: true

namespace :deploy do
  def revision_log_message
    "Copy deploy (at #{fetch(:current_revision)}) deployed as release #{fetch(:release_timestamp)} by #{local_user}"
  end

  desc 'Log details of the deploy'
  task :log_revision do
    on release_roles(:all) do
      within releases_path do
        execute :echo, %("#{revision_log_message}" >> #{revision_log})
      end
    end
  end
end
