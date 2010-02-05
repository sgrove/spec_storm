namespace :ss do
  def find_spec_files(prefix)
    require File.join(File.dirname(__FILE__), '..', 'lib', "spec_storm_helper")
    require File.join(File.dirname(__FILE__), '..', 'lib', "spec_storm")
    
    tests_folder = File.join(RAILS_ROOT, "spec", prefix)
    puts "Tests folder: #{tests_folder}"
    return SpecStorm::find_tests(tests_folder).sort
  end

  desc "Setup initial selenium environment"
  task :setup, :environment do |t, args|
    args.with_defaults(:environment => "selenium")
    require 'ftools'

    File.copy(File.join(RAILS_ROOT, 'config', 'environments', 'test.rb'),
              File.join(RAILS_ROOT, 'config', 'environments', "#{args.environment}.rb"))

    open(File.join(RAILS_ROOT, 'config', 'environments', "#{args.environment}.rb"), 'a') do |f|
      f.puts "\nmodule SpecStorm"
      f.puts "  USE_NAMESPACE_HACK = true"
      f.puts "end"
    end
  end

  desc "Prepare database with namespaces for concurrent rspec tests in path"
  task :prepare, :environment, :prefix do |t,args|
    args.with_defaults(:prefix => "", :environment => "selenium")
    require 'digest/sha1'
    require File.join(File.dirname(__FILE__), '..', 'lib', "spec_storm_helper")

    task = "spec"
    lib = "specs"


    tests = find_spec_files(args.prefix)
    puts "\t#{tests.size} test files"
    first = true


    tests.each do |test|
      prefix = SpecStorm::db_prefix_for(test)
      puts "Migrating another set of tables..."
      puts "Generating DB_PREFIX: #{test} -> #{prefix}"

      if first == true
        ["export DB_PREFIX=#{prefix}; rake db:drop RAILS_ENV=#{args.environment} --trace",
         "export DB_PREFIX=#{prefix}; rake db:create RAILS_ENV=#{args.environment} --trace"].each do |command|
          IO.popen( command ).close 
        end
      end
      
      ["export DB_PREFIX=#{prefix}; rake db:migrate RAILS_ENV=#{args.environment} --trace"].each do |cmd|
        IO.popen( cmd ).close
      end
      
      first = false
    end
  end

  desc "Launch selenium specs concurrently"
  task :launch, :threads, :environment, :prefix do |t,args|
    args.with_defaults(:threads => 2, :environment => "selenium", :prefix => "integration")
    require 'parallel'

    puts args.inspect

    tests = find_spec_files(args.prefix)

    # RSpec formatting options
    color = ($stdout.tty? ? 'export RSPEC_COLOR=1 ;' : '') # Display color when we are in a terminal

    output = {}

    until tests.empty?
      Parallel.in_threads(args.threads.to_i) do |i|
        test = tests.shift
        cmd = "export RAILS_ENV=#{args.environment}; #{color} spec -O spec/spec.opts #{test}"
        output.merge!({"#{test}" => execute_command( cmd )})
        #puts "Running results: #{output.inspect}"
      end
    end

    output.each do |key, value|
      puts "#{key}"
      puts value
    end
  end

  desc "debugging method"
  task :dbg do
    puts find_spec_files("integration").inspect
  end

  def self.execute_command(cmd)
    f = open("|#{cmd}")
    all = ''
    while out = f.gets(".")
      all+=out
      print out
      STDOUT.flush
    end
    all
  end
end
