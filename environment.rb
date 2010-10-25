require 'rubygems'
require 'ostruct'
require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = OpenStruct.new(
                 :title => 'TTC GPS',
                 :author => 'Scott Hyndman',
                 :url_base => 'http://localhost:4567/'
               )

  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
  
  set :database_url, $database_url || "postgres://postgres:1foobar1@localhost:5432/ttc-gps"
end
