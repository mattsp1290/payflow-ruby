require 'ostruct'
require 'spec_helper'

describe Payflow::Gateway do
  describe "Making a Sale" do
    it "should create a request with :sale" do
      cc = Payflow::CreditCard.new
      allow(Payflow::CreditCard).to receive(:new).and_return(cc)

      Payflow::Request.should_receive(:new).with(:sale, 10, cc, {:login=>"login", :password=>"password", :partner=>"Partner"}).and_return(double(commit: Payflow::MockResponse.new("")))
      gateway = Payflow::Gateway.new(OpenStruct.new(password: "password",  login: "login", partner: "Partner"))
      gateway.sale(10, {})
    end
  end

  describe "Making an authorization" do
    it "should create a request with :authorization" do
      cc = Payflow::CreditCard.new
      allow(Payflow::CreditCard).to receive(:new).and_return(cc)
      Payflow::Request.should_receive(:new).with(:authorization, 10, cc, {:login=>"login", :password=>"password", :partner=>"Partner"}).and_return(double(commit: Payflow::MockResponse.new("")))
      gateway = Payflow::Gateway.new(OpenStruct.new(password: "password",  login: "login", partner: "Partner"))
      gateway.authorize(10, {})
    end
  end

  describe "Making a credit" do
    it "should create a request with a :credit" do
      cc = Payflow::CreditCard.new(number: "4111111111111111", month: "1", year: "2090")
      allow(Payflow::CreditCard).to receive(:new).and_return(cc)
      Payflow::Request.should_receive(:new).with(:credit, 10, cc, {:login=>"login", :password=>"password", :partner=>"Partner"}).and_return(double(commit: Payflow::MockResponse.new("")))
      gateway = Payflow::Gateway.new(OpenStruct.new(password: "password",  login: "login", partner: "Partner"))
      gateway.credit(10, {
          number: "4111111111111111",
          month: "1",
          year: "2090"
        })
    end
  end

  describe "Initializing" do
    it "should require login" do
      gateway = Payflow::Gateway.new(OpenStruct.new(password: "password", partner: "partner"))
      gateway.should be(nil)
    end

    it "should require password" do
      gateway = Payflow::Gateway.new(OpenStruct.new(login: "login", partner: "partner"))
      gateway.should be(nil)
    end

    it "should require partner" do
      gateway = Payflow::Gateway.new(OpenStruct.new(password: "password",  login: "login"))
      gateway.should be(nil)
    end

    it "should be valid with login, password, partner" do
      gateway = Payflow::Gateway.new(OpenStruct.new(password: "password",  login: "login", partner: "Partner"))
      gateway.should be_a(Payflow::Gateway)
    end
  end
end