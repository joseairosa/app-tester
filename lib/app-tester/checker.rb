module AppTester
  class Checker < Core
    def initialize

    end

    def status(response, overwrite_output=nil, fail=false)
      if response.status == 200
        if overwrite_output.nil?
          puts "#{STRING_SUCCESS} got status #{response.status}"
        else
          puts "#{STRING_SUCCESS} #{overwrite_output}"
        end
      else
        if overwrite_output.nil?
          puts "#{STRING_WARNING} got status #{response.status}"
        else
          puts "#{STRING_WARNING} #{overwrite_output}"
        end
        exit(1) if fail
      end
    end

  end
end