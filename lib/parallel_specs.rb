require File.join(File.dirname(__FILE__), 'parallel_tests')

class ParallelSpecs < ParallelTests
  def self.run_tests(test_files, process_number)
    spec_opts = File.file?('spec/parallel_spec.opts') ? 'spec/parallel_spec.opts' : 'spec/spec.opts'
    color = ($stdout.tty? ? 'export RSPEC_COLOR=1 ;' : '')#display color when we are in a terminal
    puts "Test files: #{test_files.inspect}"

    output = ''
    test_files.each do |test_file|
      puts "\tprocessing (#{test_file})"
      prefix = Digest::SHA1.hexdigest(test_file)
      cmd = "export DB_PREFIX=nsh_#{prefix}_; export RAILS_ENV=test ; export TEST_ENV_NUMBER=#{test_env_number(process_number)} ; #{color} #{executable} -O #{spec_opts} #{test_file}"
      puts "CMD: #{cmd}"
        output += execute_command(cmd)
    end

  end

  def self.executable
    File.file?("script/spec") ? "script/spec" : "spec"
  end

  protected

  def self.find_tests(root)
    Dir["#{root}**/**/*_spec.rb"]
  end
end
