# gems
require 'rubygems'
require 'sequel'
require 'pg'
require 'sinatra'
require 'json'
require 'ttc-gps'

# local stuff
$LOAD_PATH << '.'
require 'lib/environment'
require 'lib/database'

# configure view locations
configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

# root page
get '/' do
  html "#{settings.views}/index.html"
end

# returns the closest routes to the position as JSON
get '/closest_routes' do
  user_location = GeoKit::LatLng.new(Float(params[:lat]), Float(params[:lng]))
  
  db = TTC::Database.new(settings.database_url)
  routes = db.get_routes.find_all do |route|
    route.contains? user_location
  end
  db.disconnect
  
  content_type :json
  routes.to_json
end

# gets vehicles closest to the position specified by the lat and lng GET parameters
get '/closest_vehicles' do
  
end

# gets stops closest to the position specified by lat and lng GET parameters
get '/stops' do
  user_location = GeoKit::LatLng.new(Float(params[:lat]), Float(params[:lng]))
    
  db = TTC::Database.new(settings.database_url)
  stops = db.get_stops
  
  stops.sort! do |a, b|
    user_location.distance_to(a.position) <=> user_location.distance_to(b.position)
  end
  
  db.disconnect
  
  content_type :json
  stops[0..10].to_json
end

# returns the HTML at the provided path as a string
def html path
  get_file_as_string path
end

# gets the contents of the file at path as a string
def get_file_as_string path
  File.open(path, "r").read
end