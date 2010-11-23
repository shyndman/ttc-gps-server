require 'rubygems'
require 'sinatra'
require 'json'
require 'ttc-gps'
require 'sequel'
require 'environment'

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

get '/search' do
  html "#{settings.views}/search.html"
end

# returns the closest routes to the position as JSON
get '/closest_routes/:lat/:lng' do
  user_location = GeoKit::LatLng.new(Float(params[:lat]), Float(params[:lng]))
  
  db = TTC::Database.new(settings.database_url)
  routes = db.get_routes.find_all do |route|
    route.contains? user_location
  end
  
  content_type 'application/json'
  routes.to_json
end

def html path
  get_file_as_string path
end

def get_file_as_string path
  data = ''
  f = File.open(path, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end