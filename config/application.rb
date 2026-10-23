require_relative "boot"
require "rails"
require "active_support/core_ext/numeric/time"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"
Bundler.require(*Rails.groups)

module PusulaDestek
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "Istanbul"
    config.i18n.default_locale = :tr
    config.i18n.available_locales = [:tr, :en]
    config.generators.system_tests = nil
    config.filter_parameters += [:token, :preview_token, :body, :description, :api_key]
    config.action_dispatch.cookies_same_site_protection = :lax
    config.session_store :cookie_store, key: "_pusula_session", expire_after: 12.hours
  end
end
