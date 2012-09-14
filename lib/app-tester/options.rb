module AppTester
  class Options < Core

    attr_accessor :environments
    attr_accessor :default_environment
    attr_accessor :log_connections
    attr_accessor :connection_retries

    def initialize
      @environments = {}
      @default_environment = nil
      @log_connections = false
      @connection_retries = 0
    end

    def add_environment environment
      @environments.merge! environment
    end
  end
end