ActionController::Base.class_eval do
  alias_method :original_url_for, :url_for

  def url_for(options = {})
    options.merge!( {:db_prefix => ActiveRecord::Base.table_name_prefix} ) unless options.class != Hash
    original_url_for options
  end

  alias_method :original_process, :process

  def process(request, response, method = :perform_action, *arguments) #:nodoc:
    raise StandardError.new("db_prefix cannot be nil in SpecStorm mode!") if request.params[:db_prefix].nil?
    ActiveRecord::Base.table_name_prefix = request.params[:db_prefix]
    ActiveRecord::Base.reset_all_table_names

    original_process(request, response, method, *arguments)
  end

  alias_method :original_redirect_to, :redirect_to

  def redirect_to(options = {}, response_status = {}) #:doc:
    raise ActionControllerError.new("Cannot redirect to nil!") if options.nil?

    case options
    when String
      options += "?db_prefix=#{ActiveRecord::Base.table_name_prefix}" unless options.include? "db_prefix="
    end

    original_redirect_to( options, response_status )
  end
end
