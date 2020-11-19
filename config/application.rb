require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FlashcardImages
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Add all files in `/lib` directory to the load path for require statments
    config.autoload_paths += %W(#{Rails.root}/lib)

    # https://thoughtbot.com/blog/content-compression-with-rack-deflater
    config.middleware.use Rack::Deflater
  end
end
