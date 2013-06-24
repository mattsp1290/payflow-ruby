module Payflow
  class MockReportResponse < Payflow::ReportResponse
    def initialize(request_body = "")
      @report_id = "MOCK_ID"
      @status_message = "MOCK MESSAGE"
      @status_code = 3
      @response_code = 100
    end
  end
end