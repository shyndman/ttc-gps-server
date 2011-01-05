module TTC
  class Database
    attr_accessor :connection
    
    def initialize url
      connect(url) unless url.nil?
    end
    
    def connect url
      @connection = Sequel.connect(url)
    end
    
    def disconnect 
      @connection.disconnect
    end
    
    def get_route_tag_to_id_map
      @connection[:routes].to_hash(:tag, :id)
    end
    
    def get_routes
      routes = []
      
      @connection[:routes].order(:tag).all.each do |row|
        route = TTC::Route.new
        route.tag = row[:tag]
        route.title = row[:title]
        route.bounds = GeoKit::Bounds.new(GeoKit::LatLng.new(row[:sw_lat], row[:sw_lng]),
                                          GeoKit::LatLng.new(row[:ne_lat], row[:ne_lng]))
        routes << route
      end
      
      routes
    end
    
    def insert_route route
      r = @connection[:routes]
      r.insert(
        :tag => route.tag, 
        :title => route.title,
        :sw_lat => route.bounds.sw.lat,
        :sw_lng => route.bounds.sw.lng,
        :ne_lat => route.bounds.ne.lat,
        :ne_lng => route.bounds.ne.lng
      )
    end
    
    def get_stops route_id = nil    
      # get the items
      items = @connection[:stops]
      if !route_id.nil?
        items = items.filter(:route_id => route_id)
      end
      
      stops = []
      items.all.each do |row|
        stop = TTC::Stop.new
        stop.id = row[:id]
        stop.title = row[:title]
        stop.position = Geokit::LatLng.new(row[:lat], row[:lng])
        stop.dir = row[:dir]
        stop.tag = row[:tag]
        stop.route_id = row[:route_id]
        
        stops << stop
      end
      
      stops
    end
    
    def insert_stop route_id, stop, direction
      s = @connection[:stops]
      s.insert(
        :tag => stop.tag,
        :title => stop.title,
        :lat => stop.position.lat,
        :lng => stop.position.lng,
        :dir => direction,
        :route_id => route_id
      )
    end
    
    def get_vehicle_locations route=nil
      
      # the queries below could be optimized by having the daemon perform two inserts.
      # one into the vehicle_audit table, and another into vehicle_audit_latest. the
      # query below would just select from the latest table, so the group by would
      # be unnecessary
      
      items = route.nil? \
        ? @connection["select * from vehicle_audit where id in (
      	    select max(id) from vehicle_audit group by tag
          )"]
        : @connection["select * from vehicle_audit where route_id=? and id in (
          	select max(id) from vehicle_audit group by tag
          )", route]
                  
      vehicles = []
      items.all.each do |row|
        v = TTC::Vehicle.new
        v.id = row[:tag]
        v.position = Geokit::LatLng.new(row[:lat], row[:lng])
        v.heading = row[:heading]
        v.dir = row[:dir]
        v.ts = row[:ts]
        v.routeId = row[:route_id]
        
        vehicles << v
      end
      
      vehicles
    end
    
    def insert_vehicle_audit route_id, vehicle, origin_time
      v = @connection[:vehicle_audit]
      v.insert(
        :tag => vehicle.id,
        :lat => vehicle.position.lat,
        :lng => vehicle.position.lng,
        :heading => vehicle.heading,
        :dir => vehicle.dir,
        :ts => Time.at(origin_time / 1000 - vehicle.secs_since_report),
        :route_id => route_id
      )
    end
    
    def create
      @connection.create_table? :routes do
        primary_key :id
        column :tag, String
        column :title, String
        column :sw_lat, Float
        column :sw_lng, Float
        column :ne_lat, Float
        column :ne_lng, Float
      end
      
      @connection.create_table? :stops do
        primary_key :id
        column :tag, String
        column :title, String
        column :lat, Float
        column :lng, Float
        column :dir, String
        foreign_key :route_id, :routes, :key => :id
      end
      
      @connection.create_table? :vehicle_audit do
        primary_key :id, :type=>Bignum
        column :tag, String
        column :lat, Float
        column :lng, Float
        column :heading, Float
        column :dir, String
        column :secs_since_report, Integer
        column :ts, DateTime
        foreign_key :route_id, :routes, :key => :id
        index :tag
      end
      
      @connection.create_table? :vehicle_audit_latest do
        primary_key :id, :type=>Bignum
        column :tag, String
        column :lat, Float
        column :lng, Float
        column :heading, Float
        column :dir, String
        column :secs_since_report, Integer
        column :ts, DateTime
        foreign_key :route_id, :routes, :key => :id
        index :tag
      end
    end
  end
end

if __FILE__ == $0
  require 'rubygems'
  require 'ttc-gps'
  require 'sequel'
  require 'pg'
  
  db = TTC::Database.new "postgres://postgres:1foobar1@localhost:5432/ttc-gps"
  db.get_stops.each do |stop|
    puts stop.inspect
  end
end