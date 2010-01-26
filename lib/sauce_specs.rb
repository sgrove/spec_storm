class SauceSpecs 
  def self.find_tests(root)
    Dir["#{root}**/**/*_spec.rb"]
  end
end
