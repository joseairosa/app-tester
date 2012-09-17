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

    def initialize name, options={ }
      @name = name
      @options = options
      @source = Proc.new { |parser_options, connection| yield(parser_options, connection) }
      @parser = AppTester::Parser.new(options)
      @parser.banner = @name
    end

    # Defines command options (arguments) that this test supports
    def set_cmd_options
      yield(@parser) if block_given?
    end

    # Run test
    def run(arguments=ARGV)
      append_help_option
      @parser.parse!(arguments)
      # Make sure we have enough arguments
      raise OptionParser::MissingArgument if @parser.mandatory_options + 2 > @parser.options.size + 1
      @connection = AppTester::Connection.new @parser.options[:server], @options
      @source.call(@parser.options, @connection)
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