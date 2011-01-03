require 'rubygems'
require 'ttc-gps'
require 'sequel'

lib = File.expand_path(File.join(File.dirname(__FILE__), "lib"))
require lib + '/setup'
require lib + '/database'

db = TTC::Database.new $database_url

service = TTC::TTCService.new

tags_to_ids = db.get_route_tag_to_id_map

tags_to_ids.keys.each do |tag|
  Thread.new(tag) do |myTag|
    while true
      puts "Adding vehicle audits, route=#{myTag}"
      t = Time.new
    
      begin
        res = service.get_vehicle_locations myTag.to_s
        res['vehicles'].each do |vehicle|
          db.insert_vehicle_audit tags_to_ids[myTag], vehicle, res['last_time']
        end
        puts "Finishing audit, route=#{myTag} duration=#{Time.new - t}"
      rescue 
        puts "Error occurred, route=#{myTag} error=#{$!}"
      end
    
      sleep(8)
    end  
  end
  
  sleep (8.0 / tags_to_ids.keys.length)
end

sleep # sleep forever