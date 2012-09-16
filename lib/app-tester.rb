$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# AppTester main module and namespace
module AppTester
  VERSION = '0.0.1'

  # AppTester main class
  class << self

    # Public: Options container. This will be shared across other classes
    attr_reader :options

    # Public: Tests container
    attr_reader :tests

    # Contruct AppTester framework
    #
    # ==== Yields
    #
    # * +<i>AppTester::Options</i>+ - setup available options:
    #                           add_environment: setup a new environment that can be accessed on the -s flag
    #                           default_environment: setup default environment, this will be used when no -s flag is specified
    #                           log_connection: activates Faraday log connection
    #
    # ==== Returns
    #
    # * AppTester class
    #
    # ==== Examples
    #
    #   apptester = AppTester.new do |options|
    #     options.add_environment :github => "https://github.com"
    #     options.add_environment :google => "https://google.com"
    #     options.default_environment = :google
    #   end
    def new
      @tests = {}
      @options = AppTester::Options.new
      yield @options if block_given?
      self
    end

    # Create a new test object
    #
    # ==== Attributes
    #
    # * +name <i>String</i>+ - name for this test
    #
    # ==== Yields
    #
    # * +<i>Proc</i>+ - code snippet that will executed when AppTester::Test.run is issued
    #
    # ==== Returns
    #
    # * AppTester::Test - test object
    # * nil - if no block given
    #
    # ==== Raises
    #
    # * AppTester::Error::NameEmptyError - if name is empty
    #
    # ==== Examples
    #
    #   apptester.define_test "my test" do |options, connection|
    #     result = connection.get do |request|
    #       request.url "/"
    #     end
    #     AppTester::Checker.status result
    #
    #     p AppTester::Utils.file_to_array options[:file] unless options[:file].nil?
    #   end
    def define_test name=""
      if name.empty?
        raise AppTester::Error::NameEmptyError, "Attempted to define a test without a name"
      else
        if block_given?
          @tests[name.to_sym] = AppTester::Test.new(name, @options) do |parser_options, connection|
            yield parser_options, connection
          end
        else
          @tests[name.to_sym] = nil
        end
      end
    end

    # Retrieve a test by name
    #
    # ==== Attributes
    #
    # * +name <i>String</i>+ - the test name
    #
    # ==== Returns
    #
    # * +<i>AppTester:Test</i>+ - the found test
    #
    # ==== Raises
    #
    # * +<i>AppTester::Error::TestNotFoundError</i>+ - if no test was found
    #
    # ==== Examples
    #
    #   apptester = AppTester.new do |options|
    #     options.add_environment :github => "https://github.com"
    #     options.add_environment :google => "https://google.com"
    #     options.default_environment = :google
    #   end
    #
    #   apptester.define_test "my test"
    #   my_test = apptester.get_test "my test"
    def get_test name
      raise AppTester::Error::TestNotFoundError, "Could not find test #{name}" unless @tests.keys.include?(name.to_sym)
      @tests[name.to_sym]
    end

    # Defines command line options for a given test
    #
    # ==== Attributes
    #
    # * +name <i>String</i>+ - the test name
    #
    # ==== Returns
    #
    # * +<i>AppTester:Test</i>+ - the test for which we parse the options
    #
    # ==== Yields
    #
    # * +<i>AppTester::Parser</i>+
    #
    # ==== Examples
    #
    #   apptester = AppTester.new do |options|
    #     options.add_environment :github => "https://github.com"
    #     options.add_environment :google => "https://google.com"
    #     options.default_environment = :google
    #   end
    #
    #   apptester.define_test "my test"
    #
    #   apptester.set_options_for "my test" do |test_options|
    #     test_options.set_option(:file, "-f", "--file FILE", "File to load")
    #     test_options.mandatory_options = 0
    #   end
    def set_options_for name
      test = get_test name
      yield test.parser
      test
    end

    # Run a test
    #
    # ==== Attributes
    #
    # * +name <i>String</i>+ - the test name
    # * +arguments <i>Array</i>+ - overwrite ARGV array with a custom one, useful for unit tests
    #
    # ==== Returns
    #
    # * +<i>AppTester::Test</i>+ - the test that we're running
    #
    # ==== Raises
    #
    # * +<i>AppTester::Error::TestNotFoundError</i>+ - if no test was found
    # * +<i>OptionParser::MissingArgument</i>+ - if there's a argument missing from a missmatch in the number of arguments given and mandatory_options on set_options_for method
    # * +<i>Faraday::Error::ConnectionFailed</i>+ - if there was a problem connecting to the selected server
    #
    # ==== Examples
    #
    #   d = $surechem.java.document
    #   d.get_documents("PATENTS", "US-4650884-A,US-5250534-A,US-4681893-A,US-5521184-A")
    def run_test name, arguments=ARGV
      the_test = get_test(name)
      the_test.run(arguments)
      the_test
    end

    # Load libraries to be used under this namespace
    #
    # ==== Attributes
    #
    # * +libs <i>String</i>+ - list of libraries to load
    #
    # ==== Returns
    #
    # * nil
    def load_libraries *libs
      libs.each do |lib|
        require_relative "app-tester/#{lib}"
      end
    end
    alias load_library load_libraries
  end

  load_libraries "core", "utils", "options", "test", "parser", "connection", "exceptions", "timer", "checker"
end