module SauceSpecs
  def self.db_prefix_for(file)
    #puts "Calculating for #{file}"
    dummy = File.join(File.expand_path(File.dirname(file)), (file).split('/').last)
    prefix = Digest::SHA1.hexdigest( dummy )
    "ss_#{prefix}_"
  end

  def self.patch_selenium_driver(file)
    db_prefix = self.db_prefix_for(file)

    # Monkey-patch like there's no tomorrow
    Selenium::Client::Driver.class_eval do
      attr_accessor :db_prefix
    end
    
    Selenium::Client::Driver.class_eval do
      # Make sure we don't define this twice
      unless self.instance_methods.include? "original_open"
        alias :original_open :open
        
        def open(url)
          # TODO: Regex stuff to append query properly
          new_url = url.include?("db_prefix=") ? url :"#{url}?db_prefix=#{db_prefix}"
          puts "Patching url, opening #{new_url}"
          original_open( new_url )
        end
      end
    end
  end
end
