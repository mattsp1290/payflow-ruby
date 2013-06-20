require 'spec_helper'

describe Payflow::CreditCard do
  before(:all) do

    @valid_card = Payflow::CreditCard.new(
      number: "4111111111111111",
      month: "1",
      year: "2090",
      first_name: "Steve",
      last_name: "McQueen"
      )

    @expired_card = Payflow::CreditCard.new(
      number: "4111111111111111",
      month: "1",
      year: "2011",
      first_name: "Steve",
      last_name: "McQueen"
      )
  end

  it "should know how to mask a card number" do
    number = "1234567890123456"
    Payflow::CreditCard.mask(number).should eql("XXXX-XXXX-XXXX-3456")
  end

  it "should know if the card is not expired" do
    @valid_card.expired?.should be(false)
  end

  it "should know if the card is expired" do
    @expired_card.expired?.should be(true)
  end

  it "should not be valid without a number" do
    card = Payflow::CreditCard.new(
      month: "1",
      year: "2015"
    )
    card.valid?.should be(false)
  end

  it "should know if it does not have encrypted data" do
    card = Payflow::CreditCard.new(
        month: "1",
        year: "2020",
        number: "4111111111111111"
      )
    card.encrypted?.should be(false)
  end

  it "should know if it has encrypted data" do
    card = Payflow::CreditCard.new(
        encrypted_track_data: VALID_ENCRYPTION_STRING
      )
    card.encrypted?.should be(true)
  end

  it "should automatically parse encrypted data" do
    card = Payflow::CreditCard.new(encrypted_track_data: VALID_ENCRYPTION_STRING)
    card.track2.should eql("THISISTRACK2")
    card.mp.should eql("MPDATA")
    card.mpstatus.should eql("MPSTATUS")
    card.device_sn.should eql("DEVICE_SN")
    card.ksn.should eql("KSN")
    card.last_four.should eql("5454")
    card.name.should eql("FirstName LastName")
    card.brand.should eql(:master)
  end

  it "should set brand on unencrypted cards" do
    card = Payflow::CreditCard.new(number: "4111111111111111", month: 1, year: 2090, name: "Tester McGee", security_code: 123)
    card.brand.should eql(:visa)
  end

  it "should combine the names into one" do
    card = Payflow::CreditCard.new(first_name: "Tester", last_name: "McGee")
    card.name.should eql("Tester McGee")
  end

  it "should know the last four digits of the number" do
    card = Payflow::CreditCard.new(number: "123456781119897")
    card.last_four.should eql("9897")
  end
end