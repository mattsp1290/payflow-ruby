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

  it "should not be successful if the amount is 100.01" do
    request_string = "TRXTYPE[1]=S&AMT[6]=100.01&TENDER[1]=C&ORIGID[13]=CREDITCARDREF&VENDOR[0]=&PARTNER[0]=&PWD[0]=&USER[0]=
.TRXTYPE[1]=S&AMT[6]=100.01&TENDER[1]=C&ORIGID[13]=CREDITCARDREF&VENDOR[0]=&PARTNER[0]=&PWD[0]=&USER[0]="
    response = Payflow::MockResponse.new(request_string)
    response.successful?.should be(false)
  end


end