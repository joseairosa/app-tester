module AppTester
  # @abstract Benchmark helper class
  class Timer

    # Created a new timer object
    #
    # @param message [NilClass, String] custom message to be displayed
    # @param threshold [Number] amount in ms. If this limit is passed a warning message will be displayed
    # @param method [NilClass, Symbol] method to benchmark. Optional
    # @param args [NilClass, String] arguments to be passed onto the method
    #
    # @yield code snipper to be benchmarked
    #
    # @example
    #   apptester.define_test "my test 400 threshold" do |options, connection|
    #     AppTester::Timer.new("test timer", 400) do
    #       sleep 0.5
    #     end
    #   end
    def initialize(message=nil, threshold=nil, method=nil, *args)
      beginning_time = Time.now
      if block_given?
        yield
      else
        self.send(method, args)
      end
      end_time = Time.now
      time_passed = ((end_time - beginning_time)*1000).round(3)

      threshold_message = ""
      unless threshold.nil?
        printf "#{AppTester::Utils::Strings::WARNING} " if time_passed.to_f > threshold.to_f
        threshold_message = " (threshold: #{threshold} ms)"
      end
      message = "to #{message}," if message
      puts "Time elapsed #{message} #{time_passed} milliseconds#{threshold_message}"
      puts ""
    end
  end

end