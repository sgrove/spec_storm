    dummy = File.join(File.expand_path(File.dirname(__FILE__)), (__FILE__).split('/').last)
    prefix = Digest::SHA1.hexdigest( dummy )
    puts "#{dummy} -> "
    @db_prefix = "nsh_#{prefix}_"
    puts "This spec (#{__FILE__}) should operate on the '#{@db_prefix}' db namespace"
    #DB_PREFIX: /Users/seangrove/code/rails/nshack/spec/integration/people_2_spec.rb -> nsh_cec6124a0e0792d21b9bac1bbbe4764e941cc9f6_
    puts "\t#{@db_prefix}\n\tnsh_cec6124a0e0792d21b9bac1bbbe4764e941cc9f6_"

    @browser = Selenium::SeleniumDriver.new(
                                            "localhost", 4444,
                                            "*firefox",
                                            "http://localhost:3000", 1000
                                            )
    @browser.start

    # Monkey-patch like there's no tomorrow
    @browser.class_eval do
      attr_accessor :db_prefix
    end

    @browser.instance_eval do
      alias :original_open :open

      def open(url)
        # TODO: Regex stuff to append query properly
        new_url = "#{url}?db_prefix=#{@db_prefix}"
        puts "Patching url, opening #{new_url}"
        original_open( new_url )
      end
    end

    @browser.db_prefix = @db_prefix
  end
