module Payflow
  class MockResponse < Payflow::Response
    def initialize(request_body)
      @result = {
        result: "0",
        message: "Successful",
        pn_ref: "MOCKTOKEN",
        avs_result: "0",
        cv_result: "0"
      }
    end
  end
end