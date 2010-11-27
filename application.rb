require 'rubygems'
require 'sequel'
require 'pg'
require 'sinatra'
require 'json'
require 'ttc-gps'

$LOAD_PATH << '.'
require 'lib/environment'
require 'lib/database'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  # add your helpers here
end

# root page
get '/' do
  html "#{settings.views}/index.html"
end

# returns the closest routes to the position as JSON
get '/closest_routes/:lat/:lng' do
  user_location = GeoKit::LatLng.new(Float(params[:lat]), Float(params[:lng]))
  
  db = TTC::Database.new(settings.database_url)
  routes = db.get_routes.find_all do |route|
    route.contains? user_location
  end
  db.disconnect
  
  content_type :json
  routes.to_json
end

get '/stops' do
  db = TTC::Database.new(settings.database_url)
  stops = db.get_stops
  db.disconnect
  
  content_type :json
  stops.to_json
end

def html path
  get_file_as_string path
end

def get_file_as_string path
  File.open(path, "r").read
end