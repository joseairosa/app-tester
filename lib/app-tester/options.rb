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
    #attr_accessor :connection_retries

    def initialize
      @environments = {}
      @default_environment = nil
      @log_connections = false
      #@connection_retries = 0
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
  end
end