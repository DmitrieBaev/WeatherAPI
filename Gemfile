source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.2"

gem "rails", "~> 7.0.3"
gem "puma", "~> 5.0"
gem "grape", "~> 1.6"

gem "redis", "~> 4.0"
gem "redis-namespace", '~> 1.8'

gem 'accuweather'
gem 'openweathermap', '~> 0.2.3'

gem 'resque'
gem 'resque-scheduler'
gem 'delayed_job', '~> 4.1.10'
gem 'daemons'


# gem "jbuilder"  # Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "redis", "~> 4.0"  # Use Redis adapter to run Action Cable in production
# gem "kredis"  # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "bcrypt", "~> 3.1.7"  # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "rack-cors"  # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false  # Reduces boot times through caching; required in config/boot.rb

group :development, :test do
    gem "debug", platforms: %i[ mri mingw x64_mingw ]
    gem 'rspec-rails'
    gem 'rspec-grape'
end

# group :test do
#     gem 'delayed_job_rspec'
#     gem 'webmock'
#     gem 'vcr'
# end
