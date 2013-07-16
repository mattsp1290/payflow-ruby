require 'spec_helper'

describe Payflow::Request do
  describe "initializing" do
    it "should build a sale request on action capture" do
      request = Payflow::Request.new(:sale, 100, "CREDITCARDREF")
      request.pairs.trxtype.should eql('S')
    end

    it "should build a capture request on action capture" do
      request = Payflow::Request.new(:capture, 100, "CREDITCARDREF")
      request.pairs.trxtype.should eql('D')
    end

    it "should add initial pairs" do
      request = Payflow::Request.new(:capture, 100, "CREDITCARDREF")
      request.pairs.amt.should be(100)
    end

    it "should add a comment if submitted" do
      request = Payflow::Request.new(:capture, 100, "CREDITCARDREF", {pairs: {comment1: "COMMENT"}})
      request.pairs.comment1.should eql("COMMENT")
    end

    describe "with an encrypted credit_card" do
      it "should add ENCTRACK2 to the request pairs" do
        credit_card = Payflow::CreditCard.new(encrypted_track_data: VALID_ENCRYPTION_STRING)
        request = Payflow::Request.new(:sale, 100, credit_card)
        request.pairs.enctrack2.present?.should be(true)
      end
    end
  end

  it "should have an expdate like this: MMYY" do
    cc = Payflow::CreditCard.new(number: "4111111111111111", month: 2, year: 2018)
    request = Payflow::Request.new(:sale, 100, cc)
    request.expdate(cc).should eql("0218")
  end

  it "should not explode on a bad date" do
    cc = Payflow::CreditCard.new(number: "4111111111111111", month: 2)
    request = Payflow::Request.new(:sale, 100, cc)
    request.expdate(cc).should eql("")
  end

  it "should not have an amount on voids" do
    request = Payflow::Request.new(:void, "AUTHCODE", Payflow::CreditCard.new)
    request.pairs.amt.should be(nil)
  end

  it "should handle credits" do
    request = Payflow::Request.new(:credit, 10, "AUTHCODE", {test: true})
    request.pairs.amt.should eql(10)
  end

  it "should be in test? if asked" do
    request = Payflow::Request.new(:sale, 100, "CREDITCARDREF", {test: true})
    request.test?.should be(true)
  end

  describe "commiting" do
    it "should call connection post" do
      request = Payflow::Request.new(:sale, 100, "CREDITCARDREF", {test: true})
      connection = stub
      connection.should_receive(:post).and_return(OpenStruct.new(status: 200, body: ""))
      request.stub(:connection).and_return(connection)
      request.commit
    end

    it "should return a Payflow::Response" do
      request = Payflow::Request.new(:sale, 100, "CREDITCARDREF", {test: true})
      connection = stub
      connection.should_receive(:post).and_return(OpenStruct.new(status: 200, body: ""))
      request.stub(:connection).and_return(connection)
      request.commit.should be_a(Payflow::Response)
    end

    it "should include required headers in the request" do
      request = Payflow::Request.new(:sale, 100, "CREDITCARDREF", {test: true})
      faraday_request = double
      faraday_request.should_receive(:body=)
      headers = double
      headers.should_receive(:[]=).with("Content-Type", "text/name value")
      headers.should_receive(:[]=).with("X-VPS-CLIENT-TIMEOUT", "60")
      headers.should_receive(:[]=).with("X-VPS-VIT-Integration-Product", "Payflow Gem")
      headers.should_receive(:[]=).with("X-VPS-VIT-Runtime-Version", RUBY_VERSION)
      headers.should_receive(:[]=).with("Host", Payflow::Request::TEST_HOST)
      headers.should_receive(:[]=).with("X-VPS-REQUEST-ID", "MYORDERID")

      faraday_request.stub(:headers).and_return(headers)

      connection = stub
      connection.stub(:post).and_yield(faraday_request).and_return(OpenStruct.new(status: 200, body: ""))

      request.stub(:connection).and_return(connection)
      request.commit(order_id: "MYORDERID")
    end

    it "should not call connection post if asked to mock" do
      request = Payflow::Request.new(:sale, 100, "CREDITCARDREF", {test: true, mock: true})
      connection = stub
      connection.should_not_receive(:post)
      request.stub(:connection).and_return(connection)
      request.commit
    end

    it "should return a Payflow::MockResponse if mocked" do
      request = Payflow::Request.new(:sale, 100, "CREDITCARDREF", {test: true, mock: true})
      request.commit.should be_a(Payflow::MockResponse)
    end
  end

end