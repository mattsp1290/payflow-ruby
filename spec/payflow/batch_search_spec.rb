require 'spec_helper'

describe Payflow::BatchSearch do
  it "sets the report id if successful" do
    report = Payflow::BatchSearch.new(OpenStruct.new(login: "staplesnew", password: "23swoosh!", partner: "Bypass"), {test: false})
    response = Payflow::MockReportResponse.new("")
    report.stub(:commit).and_return(response)
    response = report.create_search("1", "2014-02-01 12:00:00", "2014-02-20 00:00:00")

    response.report_id.should eql("MOCK_ID")
  end
end