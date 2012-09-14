require "faraday"

module AppTester
  class Connection

    # Public:
    attr_reader :options

    def self.new(url="", options={})
      @options = options

      # Make sure server choice makes sense
      raise OptionParser::InvalidArgument if url.nil?

      puts AppTester::Utils::Colours.dark_gray "Connecting to #{url}..."
      retries = 0
      begin
        Faraday.new(:url => url, :ssl => { :verify => false }) do |builder|
          builder.request :url_encoded
          builder.adapter :net_http
          builder.response :logger if @options.log_connections
        end
      rescue Faraday::Error::ConnectionFailed => e
        retries += 1
        retry if retries <= @options.connection_retries
        raise Faraday::Error::ConnectionFailed(e.message)
      end
    end
  end
end