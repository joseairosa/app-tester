module AppTester
  # @abstract Framework options
  # @attr_accessor default_environment [Symbol] the default environment in case command line script is executed without a server defined
  # @attr_accessor environments [Hash] the list of environments
  # @attr_accessor log_connection [TrueClass, FalseClass] if we should or not log Faraday connections
  # @todo implement connection retries
  class Options

    attr_accessor :default_environment
    attr_accessor :log_connections
    attr_accessor :environments
    attr_accessor :default_options

    def initialize
      @environments = {}
      @default_environment = nil
      @log_connections = false
      @default_options = []
    end

    # Add a new environment to the environment list. This will be used when constructing AppTester::Parser object
    #
    # @param environment [Hash] Symbol to String mapping
    #
    # @return [AppTester::Options] returns self
    def add_environment environment
      @environments.merge! environment
      self
    end

    def add_default_option(symbol, *opts, &block)
      @default_options << {symbol: symbol, opts: opts, block: block }
    end
  end
end
