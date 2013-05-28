module Payflow
  class Response
    attr_accessor :result

    def initialize(http_response)
      puts "-----------------------"
      puts http_response.inspect
      puts "-----------------------"
      @http_response = http_response
      @result = parse(http_response)
    end

    def successful?
      result[:result] == "0"
    end

    def message
      result[:message]
    end

    def authorization_token
      result[:pn_ref] || @result[:rp_ref]
    end

    def avs_result
      result[:avs_result]
    end

    def cvv_result
      result[:cv_result]
    end

    private

      def parse(http_response)
        pairs = http_response.body.split("&")
        response = {}

        pairs.each do |node|
          parse_element(response, node)
        end

        response
      end

      def parse_element(response, pair)
        response[pair.split("=").first.underscore.to_sym] = pair.split("=").last
      end
  end
end