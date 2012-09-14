require "optparse"

module AppTester
  class Parser < OptionParser

    # Public:
    attr_reader :options

    # Public:
    attr_writer :num_arguments
    POSASS = { }

    def initialize options
      @options = { }
      super do |x|
        x.separator ''
      end

      # Fallback to the first entry on the environments list if there's not default environment selected
      default_environment = options.default_environment.nil? ? options.environments.keys.first : options.default_environment
      @options[:server] = options.environments[default_environment]

      set_option(:server, "-s", "--server OPT", options.environments.keys, "Server to connect. Default: #{default_environment}")
    end

    def set_option(symbol, *opts, &block)
      #proc = Proc.new do |x|
      #  @options[symbol] = x
      #end
      if block.nil?
        on(*opts) do |x|
          @options[symbol] = x
        end
      else
        on(*opts, &block)
      end
    end

  end
end