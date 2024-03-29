require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyApplication
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.hosts.clear

    # main apis start
    $API_REGISTRY = {}
    apis = Dir.glob("#{Rails.root.join('apis')}/*")

    apis.each do |api|
      service_name = api.split('/').last.split('.').first.delete_suffix('_apis')

      api_data = JSON.parse(File.read(api)).each { |_, v| v[:service] = service_name }
      $API_REGISTRY.merge!(api_data.deep_symbolize_keys)
    end
    # main apis end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.api_only = true
    config.eager_load_paths += %W[#{config.root}/app]
    config.eager_load_paths += %W[#{config.root}/lib]
    
    services = Dir.glob("#{Rails.root.join('services')}/*").map { |t| t.split('services/').last }
    service_directories = %w[interactions models helpers store_models]

    services.each do |service|
      config.eager_load_paths += %W[#{config.root}/services/#{service}]
      service_directories.each do |service_directory|
        config.eager_load_paths += %W[#{config.root}/services/#{service}/#{service_directory}]
      end
    end

  end
end
