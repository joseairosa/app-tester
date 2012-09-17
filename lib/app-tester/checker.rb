module AppTester
  # @abstract Check module to be used within a test snippet. This can be extended to have more checks
  module Checker
    extend self

    # Check the status of a response and output to cmd
    #
    # @param response [Faraday::Response] the response object from Faraday
    # @param overwrite_output [NilClass, TrueClass] if we should overwrite default output. Useful for setting custom messages
    # @param fail [TrueClass, FalseClass] if we should force the script to halt execution
    #
    # @return [NilClass]
    def status(response, overwrite_output=nil, fail=false)
      if response.status == 200
        if overwrite_output.nil?
          puts "#{AppTester::Utils::Strings::SUCCESS} got status #{response.status}"
        else
          puts "#{AppTester::Utils::Strings::SUCCESS} #{overwrite_output}"
        end
      else
        if overwrite_output.nil?
          puts "#{AppTester::Utils::Strings::WARNING} got status #{response.status}"
        else
          puts "#{AppTester::Utils::Strings::WARNING} #{overwrite_output}"
        end
        exit(1) if fail
      end
    end

  end
end