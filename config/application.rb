require_relative "boot"

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"


Bundler.require(*Rails.groups)

module RailsApi
    class Application < Rails::Application
        config.load_defaults 7.0
        #
        config.time_zone = "Moscow"
        config.api_only = true

        config.active_job.queue_adapter = :delayed_job

        config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
        config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
    end
end
