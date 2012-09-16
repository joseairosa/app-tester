module AppTester
  class Options

    # Public:
    attr_accessor :default_environment
    # Public:
    attr_accessor :log_connections
    # Public:
    #attr_accessor :connection_retries

    def initialize
      @environments = {}
      @default_environment = nil
      @log_connections = false
      #@connection_retries = 0
    end

    def add_environment environment
      @environments.merge! environment
    end

    private

    # Private
    attr_accessor :environments
  end
end