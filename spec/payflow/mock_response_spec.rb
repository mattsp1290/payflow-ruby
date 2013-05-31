require 'spec_helper'

describe Payflow::Response do
  it "should be successful" do
    response = Payflow::MockResponse.new("RESULT=0")
    response.successful?.should be(true)
  end

  it "should have an authorization token of MOCKTOKEN" do
    response = Payflow::MockResponse.new("RESULT=0")
    response.authorization_token.should eql("MOCKTOKEN")
  end
end