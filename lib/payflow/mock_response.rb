module Payflow
  class MockResponse < Payflow::Response
    def initialize(request_body="")
      request = parse(request_body)
      generate_successful_response
      generate_failed_response if request[:amt] =~ /\.01/
    end

    private
    def generate_successful_response
      @result = {
        result: "0",
        message: "Successful",
        pn_ref: "MOCKTOKEN",
        avs_result: "0",
        cv_result: "0"
      }
    end

    def generate_failed_response
      @result = {
        result: "1",
        message: "DECLINED",
        pn_ref: "MOCKTOKEN",
        avs_result: "0",
        cv_result: "0"
      }
    end


    def parse(request_body)
      pairs = request_body.gsub(/\[\d+\]/, "").split("&")
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