require "rspec"
require "rspec-expectations"

module AppTester
  # @abstract Main object that hold all the data needed to run a test
  # @attr_reader parser [AppTester::Parser] user selected options on command line
  # @attr_reader name [String] name for this test
  # @attr_reader source [Proc] block of code that holds the test to be executed
  # @attr_reader connection [Faraday::Connection] connection handler
  # @attr_reader options [AppTester::Options] the options that the user defined when he created the framework
  class Test < Core

    attr_reader :parser
    attr_reader :name
    attr_reader :source
    attr_reader :connection
    attr_reader :options

    attr_writer :self_before_instance_eval

    include RSpec::Matchers

    def initialize name, options={ }, &block
      @name = name
      @options = options
      @source = block
      @parser = AppTester::Parser.new(options)
      @parser.banner = @name
    end

    # Defines command options (arguments) that this test supports
    def set_cmd_options
      yield(@parser) if block_given?
    end

    def arguments
      @parser.options
    end

    def get url="", parameters={}
      connection.get url, parameters
    end

    def post url="", parameters={}
      connection.post url, parameters
    end

    BacktraceObject = Struct.new(:path, :line_number, :where)

    # Run test
    def run(arguments=ARGV)
      append_help_option
      @parser.parse!(arguments)
      @parser.check_mandatory_arguments
      @connection = AppTester::Connection.new @parser.options[:server], @options
      @self_before_instance_eval = eval "self", @source.binding
      begin
        self.instance_eval &@source
      rescue RSpec::Expectations::ExpectationNotMetError => excp
        unless defined? IS_RSPEC
          # Extract and create a backtrace object
          backtrace = excp.backtrace.map { |x|
            x.match(/^(.+?):(\d+)(|:in `(.+)')$/);
            BacktraceObject.new($1, $2, $4)
          }
          line_number = 0
          # Because the correct line number is not the first on the error stack we need to iterate it and find what we want
          backtrace.each do |backtrace_entry|
            line_number = backtrace_entry.line_number if backtrace_entry.where == "block in <main>"
          end
          puts "#{AppTester::Utils::Strings::FAILED} #{excp.message} on line #{line_number}"
        end
      end
    end

    private

    # Appends helper option. This options is always available on every test
    def append_help_option
      @parser.set_option(nil, "-h", "--help", "Show this message") do
        puts @parser
        exit
      end
    end
  end
end