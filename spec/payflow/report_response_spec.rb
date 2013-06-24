require 'spec_helper'

describe Payflow::ReportResponse do
  let(:http_response) { OpenStruct.new(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<reportingEngineResponse><baseResponse><responseCode>100</responseCode><responseMsg>Request has completed successfully</responseMsg></baseResponse><runReportResponse><reportId>RE0110004581</reportId><statusCode>3</statusCode><statusMsg>Report has completed successfully</statusMsg></runReportResponse></reportingEngineResponse>\n\n\r\n")}
  let(:fail_response) { OpenStruct.new(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<reportingEngineResponse><baseResponse><responseCode>101</responseCode><responseMsg>FAIL</responseMsg></baseResponse><runReportResponse><reportId>RE0110004581</reportId><statusCode>3</statusCode><statusMsg>Report has completed successfully</statusMsg></runReportResponse></reportingEngineResponse>\n\n\r\n")}
  let(:response) { Payflow::ReportResponse.new(http_response)}
  let(:response_fail) { Payflow::ReportResponse.new(fail_response)}

  it "use the status message if successful" do
    response.message.should eql("Report has completed successfully")
  end

  it "use the response message if response not successful" do
    response_fail.message.should eql("FAIL")
  end

  it "should not be successful if result is not 100" do
    response_fail.successful?.should be(false)
  end

  it "should not be response successful if result is not 100" do
    response = Payflow::ReportResponse.new(OpenStruct.new(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<reportingEngineResponse><baseResponse><responseCode>101</responseCode><responseMsg>Request has completed successfully</responseMsg></baseResponse><runReportResponse><reportId>RE0110004581</reportId><statusCode>3</statusCode><statusMsg>Report has completed successfully</statusMsg></runReportResponse></reportingEngineResponse>\n\n\r\n"))
    response.response_successful?.should be(false)
  end

  it "should not be successful if status is not 3" do
    response = Payflow::ReportResponse.new(OpenStruct.new(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<reportingEngineResponse><baseResponse><responseCode>100</responseCode><responseMsg>Request has completed successfully</responseMsg></baseResponse><runReportResponse><reportId>RE0110004581</reportId><statusCode>4</statusCode><statusMsg>Report has completed successfully</statusMsg></runReportResponse></reportingEngineResponse>\n\n\r\n"))
    response.successful?.should be(false)
  end

  it "should be successful if reponse is successful and there is no status code" do
    response = Payflow::ReportResponse.new(OpenStruct.new(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<reportingEngineResponse><baseResponse><responseCode>100</responseCode><responseMsg>Request has completed successfully</responseMsg></baseResponse><runReportResponse><reportId>RE0110004581</reportId><statusMsg>Report has completed successfully</statusMsg></runReportResponse></reportingEngineResponse>\n\n\r\n"))
    response.successful?.should be(true)
  end

  it "should know if the response was successful" do
    response.successful?.should be(true)
  end

  it "should report_id if successful" do
    response.report_id.should eql("RE0110004581")
  end

end