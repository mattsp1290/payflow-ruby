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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
