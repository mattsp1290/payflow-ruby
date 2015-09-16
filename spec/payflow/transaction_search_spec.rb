require 'spec_helper'

describe Payflow::TransactionSearch do
  it "sets the report id if successful" do
    report = Payflow::TransactionSearch.new(OpenStruct.new(login: "staplesnew", password: "23swoosh!", partner: "Bypass"), {test: false})
    response = Payflow::MockReportResponse.new("")
    report.stub(:commit).and_return(response)
    response = report.create_search("1235")

    response.report_id.should eql("MOCK_ID")
  end
end