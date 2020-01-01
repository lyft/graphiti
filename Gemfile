# A sample Gemfile
source :rubygems

gem 'rake'
gem 'rack', '1.3.5'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'jim', '>= 0.3.3'
gem 'closure-compiler'
gem 'redis'
gem 'redised'
gem 'compass'
gem 'haml'
gem 'typhoeus', '>= 0.4.2'
gem 'yajl-ruby'
gem 'pony'

group :test do
  gem 'minitest', :require => false
  gem 'minitest-display', :require => false
end

group :development do
  gem 'sinatra-reloader', :require => 'sinatra/reloader'
  gem 'thin'
  gem 'ruby-debug19'
end

group :production do
  gem 'unicorn'
end
