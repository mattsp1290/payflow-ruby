require 'spec_helper'

describe Payflow::MockReportResponse do
  it "should be successful" do
    response = Payflow::MockReportResponse.new("")
    response.successful?.should be(true)
  end
end