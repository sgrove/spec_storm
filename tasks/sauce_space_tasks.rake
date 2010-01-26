namespace :ss do
  desc "Setup initial selenium environment"
  task :setup, :environment do |t, args|
    args.with_defaults(:environment => "selenium")
    require 'ftools'

    File.copy(File.join(RAILS_ROOT, 'config', 'environments', 'test.rb'),
              File.join(RAILS_ROOT, 'config', 'environments', "#{args.environment}.rb"))

    open(File.join(RAILS_ROOT, 'config', 'environments', "#{args.environment}.rb"), 'a') do |f|
      f.puts "\nmodule SauceSpace"
      f.puts "  USE_NAMESPACE_HACK = true"
      f.puts "end"
    end
  end

  desc "Prepare database with namespaces for concurrent rspec tests in path"
  task :prepare, :environment, :prefix do |t,args|
    args.with_defaults(:prefix => "", :environment => "selenium")
    puts "Args: #{args.inspect}"

    task = "spec"
    lib = "specs"

    require File.join(File.dirname(__FILE__), '..', 'lib', "sauce_#{lib}")
    klass = eval("Sauce#{lib.capitalize}")
    
    tests_folder = File.join(RAILS_ROOT, task, args.prefix)
    puts "Tests folder: #{tests_folder}"
    puts "using klass: #{klass.inspect}"
    tests = klass.find_tests(tests_folder)
    puts "\t#{tests.size} test files"
    first = true
    tests.each do |test|
      prefix = Digest::SHA1.hexdigest(test)
      puts "Migrating another set of tables..."
      puts "Generating DB_PREFIX: #{test} -> nsh_#{prefix}_"

      if first == true
        ["export DB_PREFIX=ss_#{prefix}_; rake db:drop RAILS_ENV=#{args.environment} --trace",
         "export DB_PREFIX=ss_#{prefix}_; rake db:create RAILS_ENV=#{args.environment} --trace"].each do |command|
          IO.popen( command ).close 
        end
      end
      
      ["export DB_PREFIX=ss_#{prefix}_; rake db:migrate RAILS_ENV=#{args.environment} --trace"].each do |cmd|
        IO.popen( cmd ).close
      end
      
      first = false
    end
  end
end
