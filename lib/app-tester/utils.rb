module AppTester

  load_libraries "utils/colors", "utils/strings"

  module Utils

    extend self

    include AppTester::Utils::Colours

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

    def check_total_results total_results
      if total_results == "0"
        puts "#{STRING_WARNING} Found #{yellow_me total_results} on this search :("
      else
        puts "Found #{yellow_me total_results} on this search ^_^"
      end
    end
  end
end