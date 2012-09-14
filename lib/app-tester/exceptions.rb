module AppTester
  module Error
    class NameEmptyError < StandardError
    end
    class BlockNotGivenError < StandardError
    end
    class TestNotFoundError < StandardError
    end
  end
end