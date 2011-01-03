#
# gets vehicles closest to the specified point
#
def get_closest_vehicles latlng, cnt=10
  begin
    db = TTC::Database.new($database_url)
    vehicles = db.get_vehicle_locations
  
    vehicles.sort! do |a, b|
      latlng.distance_to(a.position) <=> latlng.distance_to(b.position)
    end
  ensure
    db.disconnect unless db.nil?
  end
  
  vehicles[0...cnt]
end

#
# gets stops closest to the specified point
#
def get_closest_stops latlng, cnt=10
  begin
    db = TTC::Database.new($database_url)
    stops = db.get_stops
  
    stops.sort! do |a, b|
      latlng.distance_to(a.position) <=> latlng.distance_to(b.position)
    end
  
  ensure
    db.disconnect
  end
  
  stops[0...cnt]
end