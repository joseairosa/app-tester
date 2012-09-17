require "faraday"

module AppTester
  # @abstract Connection object that deals with communicating with Faraday to build new connections
  # @attr_reader options [AppTester::Options] the options that the user defined when he created the framework
  class Connection

    attr_reader :options

    # Build a new connection handler
    #
    # @param url [String] the url that will be used to set up a new connection handler
    # @param options [AppTester::Options] the options that the user defined when he created the framework
    #
    # @raise [OptionParser::InvalidArgument] if no url is specified
    # @raise [Faraday::Error::ConnectionFailed] if there was a problem connecting to the url provided
    #
    # @return [Faraday::Connection] on successfull connection
    #
    # @todo Implement connection retry
    def self.new(url="", options={})
      @options = options

      # Make sure server choice makes sense
      raise OptionParser::InvalidArgument if url.nil?

      puts AppTester::Utils::Colours.dark_gray "Connecting to #{url}..."
      retries = 0
      connection = Faraday.new(:url => url, :ssl => { :verify => false }) do |builder|
        builder.request :url_encoded
        builder.adapter :net_http
        builder.response :logger if @options.log_connections
      end
      connection
      #begin
      #
      #  connection.get do |req|
      #
      #  end
      #rescue Faraday::Error::ConnectionFailed => e
      #  retries += 1
      #  if retries <= @options.connection_retries
      #    puts AppTester::Utils::Colours.dark_gray "#{AppTester::Utils::Strings::FAILED} Failed connection to #{url}, retry attempt #{retries}..."
      #    retry
      #  end
      #  raise Faraday::Error::ConnectionFailed(e.message)
      #end
    end
  end
end