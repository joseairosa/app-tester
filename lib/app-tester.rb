$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module AppTester
  VERSION = '0.0.1'

  class << self

    # Public: Environments that can be used
    attr_reader :options

    # Public: Container of tests
    attr_reader :tests

    def new
      @tests = {}
      @options = AppTester::Options.new
      yield @options if block_given?
      self
    end

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

    def get_test name
      raise AppTester::Error::TestNotFoundError, "Could not find test #{name}" unless @tests.keys.include?(name.to_sym)
      @tests[name.to_sym]
    end

    def set_options_for name
      test = get_test name
      yield test.parser
    end

    def run_test name, arguments=ARGV
      get_test(name).run(arguments)
    end

    def load_libraries *libs
      libs.each do |lib|
        require_relative "app-tester/#{lib}"
      end
    end
    alias load_library load_libraries
  end

  load_libraries "core", "utils", "options", "test", "parser", "connection", "exceptions", "timer", "checker"
end