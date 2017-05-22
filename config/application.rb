require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module ParraShopCom
  class Application < Rails::Application
    config.action_view.sanitized_allowed_tags = 'ul', 'li', 'a', 'div'
    config.action_view.sanitized_allowed_attributes = 'id', 'class', 'data-method', 'data-confirm', 'style'
    config.action_view.sanitized_allowed_css_properties = Set.new(%w(left background background-image azimuth background-color border-bottom-color border-collapse
          border-color border-left-color border-right-color border-top-color clear color cursor direction display
          elevation float font font-family font-size font-style font-variant font-weight height letter-spacing line-height
          overflow pause pause-after pause-before pitch pitch-range richness speak speak-header speak-numeral speak-punctuation
          speech-rate stress text-align text-decoration text-indent unicode-bidi vertical-align voice-family volume white-space
          width))
    config.action_view.sanitized_allowed_css_keywords = Set.new(%w(url auto aqua black block blue bold both bottom brown center
                collapse dashed dotted fuchsia gray green !important italic left lime maroon medium none navy normal
                nowrap olive pointer purple red right solid silver teal top transparent underline white yellow))
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    I18n.config.enforce_available_locales = true
    config.i18n.available_locales = [:ru, :en]
    config.i18n.default_locale = :ru

    config.middleware.insert_before 'ActionDispatch::ParamsParser', 'HandleErrorsMiddleware'
  end
end
