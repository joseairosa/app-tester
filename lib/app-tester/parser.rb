require "optparse"

module AppTester
  # @abstract Parser handler for command line options. This uses optparse ruby gem
  # @see http://ruby-doc.org/stdlib-1.9.3/libdoc/optparse/rdoc/OptionParser.html
  # @attr_reader test_options [AppTester::Options] the options that the user defined when he created the framework
  # @attr_reader options [Hash] command line arguments that were set when executing the script
  class Parser < OptionParser

    attr_reader :test_options
    attr_reader :options

    # Build Parser object. Automatically builds with --server argument
    #
    # @param options [AppTester::Options] the options that the user defined when he created the framework
    #
    # @return [AppTester::Parser]
    def initialize options
      @options = { }
      @test_options = options
      @mandatory_arguments = {}
      @missing_arguments = []
      super do |x|
        x.separator ''
      end

      # Fallback to the first entry on the environments list if there's not default environment selected
      default_environment = @test_options.default_environment.nil? ? @test_options.environments.keys.first : @test_options.default_environment
      @options[:server] = @test_options.environments[default_environment]

      set_option(:server, "-s", "--server OPT", @test_options.environments.keys, "Server to connect. Default: #{default_environment}")

      options.default_options.each do |opt|
        set_option(opt[:symbol].to_sym, *opt[:opts], &opt[:block])
      end
    end

    # Add a new option to our optparser
    #
    # @param symbol [Symbol] identifier that will be used on the yielded block on define_test
    # @param opts [Array] command line options definition
    # @param block [Proc] custom code to be executed. Optional
    #
    # @see AppTester
    # @see OptionParser
    def set_option(symbol, *opts, &block)
      @mandatory_arguments[symbol] = {:key => symbol, :argument => opts[0], :switch => opts[1]} if opts[3] == true
      if block.nil?
        on(*opts) do |x|
          case symbol
            when :server
              @options[symbol] = @test_options.environments[x]
            else
              @options[symbol] = x
          end
        end
      else
        on(*opts, &block)
      end
    end

    def check_mandatory_arguments
      @mandatory_arguments.each{|a| a = a[1]; @missing_arguments << "Please supply #{a[:argument]} / #{a[:switch]}" unless @options[a[:key]] }
      @missing_arguments.each{|a| puts a }
      exit(1) if @missing_arguments.any?
    end

  end
end
