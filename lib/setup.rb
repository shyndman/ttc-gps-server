$database_url = $database_url || "postgres://postgres:1foobar1@localhost:5432/ttc-gps"
if not defined? $is_local
  $is_local = true
end