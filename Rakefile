namespace :gems do
  desc 'Install required gems'
  task :install do
    File.open(".gems").each { |required_gem|
      system "sudo gem install #{required_gem}"
    }
  end
end

namespace :db do
  desc 'Create the database'
  task :create, :conn_string do |t, args|
    require 'sequel'
    require File.dirname(File.expand_path(__FILE__)) + '/lib/database'
    
    puts args[:conn_string]
    db = TTC::Database.new(args[:conn_string])
    db.create
  end
end

task :environment do
  require 'environment'
end
