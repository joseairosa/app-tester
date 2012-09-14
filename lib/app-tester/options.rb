module AppTester
  class Options < Core

    attr_accessor :environments
    attr_accessor :default_environment

    def initialize
      @environments = {}
      @default_environment = nil
    end

    def add_environment environment
      @environments.merge! environment
    end
  end
end