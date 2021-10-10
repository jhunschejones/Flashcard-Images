ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/minitest' # alows mocking
require 'vcr'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  ["UNSPLASH_ACCESS_KEY", "UNSPLASH_SECRET_KEY", "PIXABAY_API_KEY", "PEXELS_API_KEY", "FLICKR_API_KEY", "FLICKR_SHARED_SECRET", "FLICKR_ACCESS_TOKEN", "FLICKR_ACCESS_SECRET", "SHUTTERSTOCK_TOKEN"].each do |key|
    config.filter_sensitive_data("<#{key}>") { ENV[key] }
  end
end

def login_as(user)
  post login_path, params: { email: user.email, password: "secret" }
end

def stub_const(klass, const, value)
  old = klass.const_get(const)
  klass.send(:remove_const, const)
  klass.const_set(const, value)
  yield
ensure
  klass.send(:remove_const, const)
  klass.const_set(const, old)
end
