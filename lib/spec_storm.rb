# SpecStorm
puts "Parsing SpecStorm loader"
module SpecStorm
  class SpecStormError < StandardError; end #:nodoc
  class NoDBPrefixSpecified < SpecStormError; end #:nodoc

  if SpecStorm.const_defined?("USE_NAMESPACE_HACK") and SpecStorm::USE_NAMESPACE_HACK == true
    puts 'Loading SpecStorm patches...'

    # Used for creating/migrating the databases (if we don't have any urls to get db_prefix token from)
    ActiveRecord::Base.table_name_prefix = ENV['DB_PREFIX'] unless ENV['DB_PREFIX'].nil?

    require 'active_record_ext'
    require 'action_controller_ext'
    require 'action_view_ext'

    puts 'Finished loading SpecStorm patches'
  end
end
