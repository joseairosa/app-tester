module AppTester
  module Checker
    extend self

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