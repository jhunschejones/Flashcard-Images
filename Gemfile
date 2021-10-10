source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'rails', '~> 6.1.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.0'
gem 'sass-rails', '>= 6'
gem 'closure-compiler', git: 'https://github.com/hmdne/closure-compiler', tag: '1.1.17'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'redis', '~> 4.0'
gem 'httparty'

gem 'bcrypt', '~> 3.1.7'
gem 'lockbox'
gem 'blind_index'

gem 'pixabay-api', require: 'pixabay', git: 'https://github.com/jhunschejones/pixabay'
gem 'pexels'
gem 'flickr'
gem 'font_awesome5_rails'
gem 'bulma-rails'

gem 'newrelic_rpm'
gem 'newrelic-infinite_tracing'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'minitest-rails'
  gem 'database_cleaner'
  gem 'mocha'
  gem 'webmock'
  gem 'vcr'
end
