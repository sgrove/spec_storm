ActionView::Helpers::UrlHelper.class_eval do
  unless self.const_defined?("SpecStormLoaded")
    puts "Patching ActiveView::Base"
    SpecStormLoaded = true
    
    alias_method :original_url_to, :url_for

    def url_for(options = {})
      # TODO: Regex stuff to only append this when necessary
      case options
      when String
        return "#{original_url_to( options )}?db_prefix=#{ActiveRecord::Base.table_name_prefix}" unless options.include? "db_prefix="
      end
      
      original_url_to options
    end
    
    alias_method :original_link_to, :link_to
    
    def link_to(*args, &block)
      logger.debug "link_to:\t#{args.inspect}"
      
      arguments = args.join(",")
      if block_given?
        return eval("original_link_to( #{arguments}")
      end
      
      original_link_to *args
    end
  end
end
