module AppTester
  module Utils
    extend self

    def wait_for_search_completion last_response
      # Check and parse last response...
      if last_response.status != 200
        puts "#{STRING_FAILED} Error performing search!"
      else
        parsed_submit_result = JSON.parse last_response.body
        srch_hash = parsed_submit_result["data"]["hash"]
        puts "Search hash: #{srch_hash}"

        # Wait for completion
        status_response = CONNECTION.get do |req|
          req.url "/search/#{srch_hash}/status"
        end
        attempts = 1

        until ((status_response.body.include? "Searching finished") || attempts >= 20)
          sleep 1
          status_response = CONNECTION.get do |req|
            req.url "/search/#{srch_hash}/status", :dev => "68fc39fb273d162f40cca089b31a2f98"
          end
          puts "Waiting for search to complete... attempts=#{attempts}"
          attempts += 1
        end

        if attempts == 20
          puts "#{STRING_FAILED} Search did not complete within allotted time"
        end

        srch_hash
      end
    end

    def read_file_to_lines file
      lines = []
      File.open(file, "r") do |infile|
        while (line = infile.gets)
          lines.push(line.gsub("\n", "").rstrip)
        end
      end
      lines
    end

    def bold_me string, block=true
      puts "" if block
      puts "\033[1;30m#{string}\033[0m"
    end

    def yellow_me string
      "\033[1;33m#{string}\033[0m"
    end

    def check_total_results total_results
      if total_results == "0"
        puts "#{STRING_WARNING} Found #{yellow_me total_results} on this search :("
      else
        puts "Found #{yellow_me total_results} on this search ^_^"
      end
    end

    def timer(threshold=nil, message=nil, method=nil, *args)
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
        printf "#{STRING_WARNING} " if time_passed.to_f > threshold.to_f
        threshold_message = " (threshold: #{threshold} ms)"
      end

      if message.nil?
        bold_me "Time elapsed #{time_passed} milliseconds#{threshold_message}", false
      else
        bold_me "Time elapsed to #{message}, #{time_passed} milliseconds#{threshold_message}", false
      end
    end
  end
end