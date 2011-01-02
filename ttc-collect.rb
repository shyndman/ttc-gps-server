require 'rubygems'
require 'ttc-gps'
require 'sequel'

lib = File.expand_path(File.join(File.dirname(__FILE__), "lib"))
require lib + '/setup'
require lib + '/database'

db = TTC::Database.new
db.connect $database_url

service = TTC::TTCService.new

tags_to_ids = db.get_route_tag_to_id_map

while true
  tags_to_ids.keys.each do |tag|
    puts "Adding vehicle audits, route=#{tag}"
    t = Time.new
    
    begin
      res = service.get_vehicle_locations tag.to_s
      res['vehicles'].each do |vehicle|
        db.insert_vehicle_audit tags_to_ids[tag], vehicle, res['last_time']
      end
      puts "Finishing audit, route=#{tag} duration=#{Time.new - t}"
    rescue 
      puts "Error occurred, route=#{tag} error=#{$!}"
    end
    
    sleep(2)
  end  
end