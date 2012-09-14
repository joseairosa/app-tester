require "optparse"

module AppTester
  class Parser < OptionParser

    #Public:
    attr_reader :test_options

    # Public:
    attr_reader :options

    # Public:
    attr_writer :num_arguments

    # Public:
    attr_accessor :mandatory_options

    def initialize options
      @options = { }
      @test_options = options
      @mandatory_options = 0
      super do |x|
        x.separator ''
      end

      # Fallback to the first entry on the environments list if there's not default environment selected
      default_environment = @test_options.default_environment.nil? ? @test_options.environments.keys.first : @test_options.default_environment
      @options[:server] = @test_options.environments[default_environment]

      set_option(:server, "-s", "--server OPT", @test_options.environments.keys, "Server to connect. Default: #{default_environment}")
    end

    def set_option(symbol, *opts, &block)
      #proc = Proc.new do |x|
      #  @options[symbol] = x
      #end
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

  end
end