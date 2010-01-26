# SauceSpace
module SauceSpace
  class SauceSpaceError < StandardError; end #:nodoc
  class NoDBPrefixSpecified < SauceSpaceError; end #:nodoc

  if SauceSpace.const_defined?("USE_NAMESPACE_HACK") and SauceSpace::USE_NAMESPACE_HACK == true
    logger.debug 'Loading sauce space patches...'

    # Used for generating the databases (no urls to get db_prefix token from)
    ActiveRecord::Base.table_name_prefix = ENV['DB_PREFIX'] unless ENV['DB_PREFIX'].nil?

    require 'active_record_ext'
    require 'action_controller_ext'
    require 'action_view_ext'

    logger.debug 'Finished loading sauce space patches'
  end
end
