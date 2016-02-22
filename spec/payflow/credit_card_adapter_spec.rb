require 'spec_helper'

describe Payflow::CreditCardAdapter do
  it "should work with payflow encrypted cards" do

    cc = {
      expiration:"2005",
      last_four_digits:"1111",
      name:"JOHAPPY/ SLAPPY",
      device_sn:"319CFB0406002900",
      ksn:"9011880B24945600011F",
      mp:"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      mpstatus:"209875",
      track2:"591DF02FF169607B49A3BEB2D9CAA6C958CA2F3034FB200C31D23A6CC246290CCA355CD467246E22",
      encrypted:"true",
      month: "1",
      year: "2090"
    }
    reference = Payflow::CreditCardAdapter.run(cc)
    expect(reference).to be_a(Payflow::CreditCard)
  end

  it "should work with unencrypted cards" do
    cc = {
      number: '411111111111',
      month: "1",
      year: "2090"
    }
    reference = Payflow::CreditCardAdapter.run(cc)
    expect(reference).to be_a(Payflow::CreditCard)
  end

end