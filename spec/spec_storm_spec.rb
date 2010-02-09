require File.dirname(__FILE__) + '/spec_helper'

# For ActiveRecord extension testing
class Category < ActiveRecord::Base; end
class Categorization < ActiveRecord::Base; end
class Smarts < ActiveRecord::Base; end
class CreditCard < ActiveRecord::Base
  class PinNumber < ActiveRecord::Base
    class CvvCode < ActiveRecord::Base; end
    class SubCvvCode < CvvCode; end
  end
  class SubPinNumber < PinNumber; end
  class Brand < Category; end
end


describe SpecStorm do
  context "ActionController" do
    before(:each) do
      @db_prefix = "dummy_prefix_"
      set_table_prefix_to @db_prefix

      @request = ActionController::TestRequest.new
      @params = {}
      @rewriter = ActionController::UrlRewriter.new(@request, @params)
    end

    it "should have a blank db prefix if enabled but not set" do
      clear_table_prefix

      rewritten_url = @rewriter.rewrite(:protocol => 'https://', :controller => 'c', :action => 'a', :id => 'i')
      rewritten_url.should == "https://test.host/c/a/i?db_prefix="
    end

    it "should inject a db prefix when generating a url" do
      rewritten_url = @rewriter.rewrite(:protocol => 'https://', :controller => 'c', :action => 'a', :id => 'i')
      rewritten_url.should == "https://test.host/c/a/i?db_prefix=dummy_prefix_"
    end

    it "should not override a pre-existing db_prefix when generating a url" do
      rewritten_url = @rewriter.rewrite(:protocol => 'https://', :controller => 'c', :action => 'a', :id => 'i', :db_prefix => "preexisting_dummy_prefix_")
      rewritten_url.should == "https://test.host/c/a/i?db_prefix=preexisting_dummy_prefix_"
    end
  end

  context "ActiveRecord" do
    before(:each) do
      @db_prefix = "dummy_prefix_"
      set_table_prefix_to @db_prefix
    end

    it "should modify database table name prefixes" do
      puts "#{Category.table_name_prefix}|#{Category.table_name}|#{Category.table_name_suffix}"
      "#{Category.table_name}".should == "dummy_prefix_categories"
    end
  end

  protected

  def set_table_prefix_to db_prefix
    @db_prefix = db_prefix
    ActiveRecord::Base.prefix_and_reset_all_table_names_to @db_prefix
  end

  def clear_table_prefix
    ActiveRecord::Base.prefix_and_reset_all_table_names_to ""
  end
end
