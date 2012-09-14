module AppTester
  class Test < Core
    # Public: Parser object. This will be user to handle the options provided by the user on a specific test
    attr_reader :parser

    # Public:
    attr_reader :name

    # Public:
    attr_reader :source

    # Public:
    attr_reader :connection

    # Public
    attr_reader :options

    def initialize name, options={ }
      @name = name
      @options = options
      @source = Proc.new { |parser_options, connection| yield(parser_options, connection) }
      @parser = AppTester::Parser.new(options)
      @parser.banner = @name
    end

    def set_cmd_options
      yield(@parser) if block_given?
    end

    def run(arguments=ARGV)
      append_help_option
      @parser.parse!(arguments)
      # Make sure we have enough arguments
      raise OptionParser::MissingArgument if @parser.mandatory_options + 2 > @parser.options.size + 1
      @connection = AppTester::Connection.new @parser.options[:server], @options
      @source.call(@parser.options, @connection)
    end

    private

    def append_help_option
      @parser.set_option(nil, "-h", "--help", "Show this message") do
        puts @parser
        exit
      end
    end
  end
end