source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.1"

gem "active_model_serializers"
gem "committee-rails"
# bundlerはrequireでbootsnapを読み込まない
# これは、requireするライブラリの名前がgemの名前と異なる場合によく使われる。
gem 'bootsnap', require: false
gem "hashid-rails"
gem "kaminari"
gem "mysql2", "~> 0.5"
gem "puma", ">= 5.0"
gem 'rack-cors'
gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "ransack"
gem "ridgepole"
gem "seed-fu"
gem 'aws-sdk-s3'
gem 'rack-cors'
gem "ruby-openai"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]

  # gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-json_matcher"
  gem "rspec-rails"
  gem "webmock"
end

group :development do
  gem "annotate"
  gem "rubocop"
  gem "rubocop-rspec"
  gem "web-console"
end
