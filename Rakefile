require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'sinatra/activerecord/rake'

task :environment do
  require './graphiti'
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

namespace :graphiti do

  desc 'Rebuild Metrics List'
  task :metrics => :environment do
    list = Metric.all true
    puts "Got #{list.length} metrics"
  end

  desc 'Send email reports per dashboard. Needs `reports` settings in settings.yml'
  task :send_reports, :environment do
    Dashboard.send_reports
  end

end

task "db:migrate" => :environment
