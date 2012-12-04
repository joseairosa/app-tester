$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
##
# @abstract AppTester main module and namespace
module AppTester
  VERSION = '0.1.1'

  # @abstract AppTester main class
  # @attr_reader [AppTester::Options] Options container. This will be shared across other classes
  # @attr_reader [Hash] A hash of tests. Values take the format of AppTester::Test
  class << self

    attr_reader :options
    attr_reader :tests

    # Construct AppTester framework
    #
    # @yield [options] Gives the user the possibility to set generic options for the framework
    # @yieldparam options [AppTester::Options] the options object
    # @return [AppTester]
    # @example Start AppTester handler
    #   apptester = AppTester.new do |options|
    #     options.add_environment :github => "https://github.com"
    #     options.add_environment :google => "https://google.com"
    #     options.default_environment = :google
    #     options.log_connection = true
    #   end
    def new
      @tests = []
      @options = AppTester::Options.new
      yield @options if block_given?
      self
    end

    # Create a new test object
    #
    # @param name [String] name for this test
    #
    # @yield code snippet that will be executed when AppTester::Test.run is issued
    #
    # @return [AppTester::Test] if the creation of this test was successfull with a block
    # @return [NilClass] if the creation of this test was successfull with no block
    #
    # @raise [AppTester::Error::NameEmptyError] if name is empty
    #
    # @example Define a new test
    #   apptester.define_test "my test" do |cmd_options, connection|
    #     result = connection.get do |request|
    #       request.url "/"
    #     end
    #     AppTester::Checker.status result
    #
    #     p AppTester::Utils.file_to_array cmd_options[:file] unless cmd_options[:file].nil?
    #   end
    def define_test name="", &block
      if name.empty?
        raise AppTester::Error::NameEmptyError, "Attempted to define a test without a name"
      end
      block = Proc.new{} unless block_given?
      test = AppTester::Test.new(name, @options, &block)
      @tests.push title: name, test: test
      test
    end

    # Retrieve a test by name
    #
    # @param name [String] test to retrieve
    #
    # @return [AppTester::Test] found test
    #
    # @raise [AppTester::Error::TestNotFoundError] if no test was found
    #
    # @example Get a pre-defined test
    #   apptester = AppTester.new do |options|
    #     options.add_environment :github => "https://github.com"
    #     options.add_environment :google => "https://google.com"
    #     options.default_environment = :google
    #   end
    #
    #   apptester.define_test "my test"
    #   my_test = apptester.get_test "my test"
    def get_test name
      entry = @tests.find { |t| t[:title] == name }
      if entry.nil?
        raise AppTester::Error::TestNotFoundError, "Could not find test #{name}" 
      end
      entry[:test]
    end

    # Defines command line options for a given test
    #
    # @param name [String] test name to which we want to define the command line options
    #
    # @return [AppTester::Test] the test for which we parsed the options
    #
    # @yield [options_parser] set the command line options for this test
    # @yieldparam cmd_options [AppTester::Parser] command line options parser object
    #
    # @example Set options for a test
    #   apptester = AppTester.new do |options|
    #     options.add_environment :github => "https://github.com"
    #     options.add_environment :google => "https://google.com"
    #     options.default_environment = :google
    #   end
    #
    #   apptester.define_test "my test"
    #
    #   apptester.set_options_for "my test" do |options_parser|
    #     options_parser.set_option(:file, "-f", "--file FILE", "File to load")
    #   end
    def set_options_for name
      test = get_test name
      yield test.parser
      test
    end

    # Run a test
    #
    # @param name [String] test name that we want to run
    # @param arguments [Array] overwrite ARGV array with a custom one, useful for unit tests
    #
    # @return [AppTester::Test] the test that we're running
    #
    # @raise [AppTester::Error::TestNotFoundError] if no test was found
    # @raise [Faraday::Error::ConnectionFailed] if there was a problem connecting to the selected server
    #
    # @example Run a test
    #   apptester = AppTester.new do |options|
    #     options.add_environment :github => "https://github.com"
    #     options.add_environment :google => "https://google.com"
    #     options.default_environment = :google
    #   end
    #   apptester.define_test "my test" do |cmd_options, connection|
    #     result = connection.get do |request|
    #       request.url "/"
    #     end
    #     AppTester::Checker.status result
    #
    #     p AppTester::Utils.file_to_array cmd_options[:file] unless cmd_options[:file].nil?
    #   end
    #
    #   my_test = apptester.run_test
    def run_test name, arguments=ARGV
      the_test = get_test(name)
      the_test.run(arguments)
      the_test
    end

    # Run all tests
    #
    # @raise [Faraday::Error::ConnectionFailed] if there was a problem connecting to the selected server
    def run_all
      @tests.each do |test|
        run_test test[:title]
      end
    end

    private
    # Load libraries to be used under this namespace
    #
    # @param libs [String] list of libraries to load
    #
    # @return [NilClass]
    def load_libraries *libs
      libs.each do |lib|
        require_relative "app-tester/#{lib}"
      end
    end
    alias load_library load_libraries
  end

  load_libraries "core", "utils", "options", "test", "parser", "connection", "exceptions", "timer", "checker"
end
