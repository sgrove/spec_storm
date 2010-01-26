puts "Loading SauceHack"
puts "\t#{ActiveRecord.inspect}"
puts "\tPrefix: #{ActiveRecord::Base.table_name_prefix}"
puts "\tENV['DB_PREFIX']: #{ENV['DB_PREFIX']}"
ActiveRecord::Base.table_name_prefix = ENV['DB_PREFIX'] unless ENV['DB_PREFIX'].nil?
puts "\tPrefix: #{ActiveRecord::Base.table_name_prefix}"






