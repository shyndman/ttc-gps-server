# gems
require "rubygems"
require "bundler/setup"
require 'sequel'
require 'pg'
require 'sinatra/base'
require 'json'
require 'ttc-gps'

# local stuff
$LOAD_PATH << File.dirname(__FILE__)
require 'lib/setup'
require 'lib/database'
require 'lib/util'
require 'lib/service'

#
# Application server class.
#
class AvoidTheCold < Sinatra::Base

  #
  # configure view locations
  #
  configure do
    set :views, "#{File.dirname(__FILE__)}/views"
    set :public, "#{File.dirname(__FILE__)}/public"
  end


  #
  # root page
  #
  get '/' do
    html "#{settings.views}/index.html"
  end


  #
  # gets vehicles closest to the position specified by the lat and lng GET parameters
  #
  get '/vehicles' do
    user_location = GeoKit::LatLng.new(Float(params[:lat]), Float(params[:lng]))
  
    content_type :json
    get_closest_vehicles(user_location, nil, 10).to_json
  end
  
  
  #
  # gets vehicles closest to the position specified by the lat and lng GET parameters,
  # on the specified route
  #
  get '/vehicles/:route' do
    
  end


  #
  # gets stops closest to the position specified by lat and lng GET parameters
  #
  get '/stops' do
    user_location = GeoKit::LatLng.new(Float(params[:lat]), Float(params[:lng]))

    content_type :json
    get_closest_stops(user_location).to_json
  end
  
  
  error do
    if request.path == "/"
      return html("#{settings.views}/error.html") 
    end
    
    content_type :json
    { :error => true }.to_json
  end
end

AvoidTheCold.run! :host => 'localhost', :port => 8080