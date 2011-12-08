source :rubygems

gem 'rake'
gem 'sinatra'
gem 'haml'
gem 'sass'
gem 'compass', '~> 0.12.alpha'
gem 'coffee-script'
gem 'uglifier'
gem 'redcarpet', '~> 1.17.2'
gem 'sqlite3'
gem 'i18n'
gem 'activesupport'
gem 'faraday-stack'
gem 'bcrypt-ruby'
gem 'will_paginate', '~> 3.0.2'
gem 'hpricot'

gem 'sinatra-activerecord'
gem 'activerecord'

group :development do
  gem 'thin'
  gem 'shotgun'
end

group :development, :test do
  unless RUBY_VERSION == '1.9.3'
    gem 'ruby-debug', :require => nil, :platforms => :mri_18
    gem 'ruby-debug19', :require => nil, :platforms => :mri_19
  end
end

group :production do
  gem 'therubyracer-heroku', '~> 0.8.1.pre3'
end
