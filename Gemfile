source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.3'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'jbuilder', '~> 2.10', '>= 2.10.1'
gem 'pagy', '~> 3.8', '>= 3.8.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rack-cors', '~> 1.1', '>= 1.1.1'

group :development, :test do
  gem 'bullet', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.1'
  gem 'pry-byebug', '~> 3.9', platform: :mri
  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
end

group :development do
  gem 'annotate', '~> 2.6.5'
  gem 'brakeman', '~> 4.7'
  gem 'listen', '~> 3.2'
  gem 'rails_best_practices', '~> 1.20'
  gem 'reek', '~> 6.0', '>= 6.0.1'
  gem 'rubocop-rails', '~> 2.8', '>= 2.8.1'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'faker', '~> 2.14'
  gem 'rspec-json_expectations', '~> 2.2'
  gem 'shoulda-matchers', '~> 4.4', '>= 4.4.1'
  gem 'simplecov', '~> 0.19.0', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
