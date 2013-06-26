# Payflow

A Ruby Library wrapper to the Payflow Gateway. This gem was created specifically to add magnetic card reader and decryption support not found in any other Payflow gems.

## Installation

Add this line to your application's Gemfile:

    gem 'payflow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install payflow

## Usage

    credit_card = Payflow::CreditCard.new(encrypted_track_data: "XXXXXXXXXXXX")
    gateway = Payflow::Gateway.new(OpenStruct.new(login: "me", password: "credentials", partner: "PayPal"))
    response = gateway.sale(100, credit_card)

## Authorize and Delayed Capture

    response = gateway.authorize(10, credit_card)
    gateway.capture(10, response.authorization_token)

## Making a sale from a tokenized payment method

    gateway.sale(10, response.authorization_token)
    
## Reports

  The Payflow gem also supports the Payflow Report API. This is a separate API but supports the same credentials.
  
    report = Payflow::SettlementReport.new(OpenStruct(login: "me", password: "password", partner: "PayPal"))
    
    if report.create_report("YOUR PROCESSOR", "2013-01-01", "2013-01-02").successful?
      report.fetch
    end


## Testing

  The gateway initialization includes a test and mock setting. __Test__ will use the Payflow pilot server and __Mock__ will return a MockResponse that inherits from Payflow::Response so that you can use it exactly as you would a real response

    gateway = Payflow::Gateway.new(OpenStruct.new(login: "me", password: "credentials", partner: "PayPal"), {test: true, mock: true})

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
