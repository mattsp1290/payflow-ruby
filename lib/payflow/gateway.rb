module Payflow

  class Gateway

    attr_accessor :login, :partner, :password

    def self.new(merchant_account, options = {})
      super if requires!(merchant_account, :login, :password, :partner)
    end

    def initialize(merchant_account, options = {})
      @login = merchant_account.login
      @partner = merchant_account.partner
      @password = merchant_account.password
      @options = options.merge({
        login: login,
        password: password,
        partner: partner
      })
    end

    def request(action, money, reference, options)
      Payflow::Request.new(action, money, reference, options.merge(@options))
    end

    def authorize(money, credit_card_or_reference, options = {})
      request(:authorization, money, credit_card_or_reference, options).commit(options)
    end

    def sale(money, credit_card_or_reference, options = {})
      request(:sale, money, credit_card_or_reference, options).commit(options)
    end

    def refund(money, reference, options = {})
      request(:credit, money, reference, options).commit(options)
    end

    def capture(money, authorization, options = {})
      request(:capture, money, authorization, options).commit(options)
    end

    def void(authorization, options = {})
      request(:void, nil, authorization, options).commit(options)
    end

    private
      def self.requires!(object, *required_fields)
        required_fields.each do |field|
          return false unless object.respond_to?(field)
        end
        true
      end
  end
end