module AppTester
  class Timer

    def initialize(message=nil, threshold=nil, method=nil, *args)
      beginning_time = Time.now
      if block_given?
        yield
      else
        self.send(method, args)
      end
      end_time = Time.now
      time_passed = ((end_time - beginning_time)*1000).round(3)
      printf "   "

      threshold_message = ""
      unless threshold.nil?
        printf "#{AppTester::Utils::Strings::WARNING} " if time_passed.to_f > threshold.to_f
        threshold_message = " (threshold: #{threshold} ms)"
      end

      if message.nil?
        puts AppTester::Utils::Colours.dark_gray "Time elapsed #{time_passed} milliseconds#{threshold_message}"
      else
        puts AppTester::Utils::Colours.dark_gray "Time elapsed to #{message}, #{time_passed} milliseconds#{threshold_message}"
      end
    end

  end
end