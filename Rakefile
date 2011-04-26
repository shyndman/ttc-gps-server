namespace :store do
  desc 'Create tables in the relational backing store'
  task :create_relational, :conn_string do |t, args|
    require 'sequel'
    require File.dirname(File.expand_path(__FILE__)) + '/lib/database'
    
    puts args[:conn_string]
    db = TTC::Database.new(args[:conn_string])
    db.create
  end

  
end
