require "faraday"

module AppTester
  class Connection
    def self.new(url="")
      # Make sure server choice makes sense
      raise OptionParser::InvalidArgument if url.nil?
      AppTester::Utils.bold_me "Connecting to #{url}..."
      Faraday.new(:url => url, :ssl => { :verify => false }) do |builder|
        builder.request :url_encoded
        builder.adapter :net_http
        #builder.response :logger
      end
    end
  end
end