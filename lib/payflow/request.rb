require 'faraday'

module Payflow

  CARD_MAPPING = {
    :visa => 'Visa',
    :master => 'MasterCard',
    :discover => 'Discover',
    :american_express => 'Amex',
    :jcb => 'JCB',
    :diners_club => 'DinersClub',
    :switch => 'Switch',
    :solo => 'Solo'
  }

  TRANSACTIONS = {
    :sale           => "S",
    :authorization  => "A",
    :capture        => "D",
    :void           => "V",
    :credit         => "C"
  }

  DEFAULT_CURRENCY = "USD"

  SWIPED_ECR_HOST       = "MAGT"
  MAGTEK_CARD_TYPE      = 1
  REGISTERED_BY         = "PayPal"
  ENCRYPTION_BLOCK_TYPE = 1

  CREDIT_CARD_TENDER  = 'C'

  class Request
    attr_accessor :pairs

    TIMEOUT = 60

    TEST_HOST = 'pilot-payflowpro.paypal.com'
    LIVE_HOST = 'payflowpro.paypal.com'

    def initialize(action, money, credit_card_or_reference, options = {})
      @options = options
      
      case action
      when :sale, :authorize
        build_sale_or_authorization_request(action, money, credit_card_or_reference, options)
      when :capture
        build_reference_request(action, money, credit_card_or_reference, options)
      when :void
        build_reference_request(action, money, credit_card_or_reference, options)
      end
    end

    def build_sale_or_authorization_request(action, money, credit_card_or_reference, options)
      if credit_card_or_reference.is_a?(String)
        build_reference_sale_or_authorization_request(action, money, credit_card_or_reference, options)
      else
        build_credit_card_request(action, money, credit_card_or_reference, options)
      end
    end

    def build_reference_sale_or_authorization_request(action, money, reference, options)
      self.pairs  = initial_pairs(action, money)
      pairs.pnref = reference
    end

    def build_credit_card_request(action, money, credit_card, options)
      self.pairs = initial_pairs(action, money)
      add_credit_card!(credit_card)
    end

    def build_reference_request(action, money, authorization, options)
      self.pairs  = initial_pairs(action, money)
      pairs.pnref = authorization
    end

    def add_credit_card!(credit_card)
      pairs[:tender]    = CREDIT_CARD_TENDER
      pairs[:card_type] = credit_card_type(credit_card)

      if credit_card.encrypted?
        add_encrypted_credit_card!(credit_card)
      else
        add_keyed_credit_card!(credit_card)
      end
    end

    def credit_card_type(credit_card)
      return '' if credit_card.brand.blank?

      CARD_MAPPING[credit_card.brand.to_sym]
    end

    def expdate(creditcard)
      year  = sprintf("%.4i", creditcard.year.to_s.sub(/^0+/, ''))
      month = sprintf("%.2i", creditcard.month.to_s.sub(/^0+/, ''))

      "#{year}#{month}"
    end

    def commit(options = {})
      nvp_body = build_request_body

      puts "------- REQUEST ------------------"
      puts nvp_body
      puts "-------------------------"

      response = connection.post do |request|
        request.headers["Content-Type"] = "text/name value"
        request.headers["X-VPS-CLIENT-TIMEOUT"] = TIMEOUT.to_s
        request.headers["X-VPS-VIT-Integration-Product"] = "Payflow Gem"
        request.headers["X-VPS-VIT-Runtime-Version"] = RUBY_VERSION
        request.headers["Host"] = test? ? TEST_HOST : LIVE_HOST
        request.headers["X-VPS-REQUEST-ID"] = SecureRandom.base64(20)
        request.body = nvp_body
        request.body = "TRXTYPE=A&TENDER=C&VENDOR=bypassb&USER=bypassb&PARTNER=PayPal&PWD[11]=pwBypass15!&VERBOSITY=HIGH&CARDTYPE=1&SWIPEDECRHOST=MAGT&ENCTRACK2=5600EE18B9AA552B4BBF79B7DB6EB203A402858ED3D1D99A17FF746B46FF819A0B7A07FB1B54539C&AMT=11.00&ENCMP=63456534653465346&KSN=9010980B068EB5000009&MPSTATUS=000002&ENCRYPTIONBLOCKTYPE=1&REGISTEREDBY=PayPal&MAGTEKCARDTYPE=1"#&DEVICESN=73A6EB0218000D00"
      end

      Payflow::Response.new(response)
    end

    def test?
      return true
    end

    private
      def endpoint
        "https://#{test? ? TEST_HOST : LIVE_HOST}"
      end

      def connection
        @conn ||= Faraday.new(:url => endpoint) do |faraday|
          faraday.request  :url_encoded
          faraday.response :logger
          faraday.adapter  Faraday.default_adapter
        end
      end

      def initial_pairs(action, money)
        OpenStruct.new(
          amt: money,
          trxtype: TRANSACTIONS[action]
        )
      end

      def add_keyed_credit_card!(credit_card)
        pairs.acct    = credit_card.number
        pairs.expdate = expdate(credit_card)
        pairs.cvv2    = credit_card.verification_value if credit_card.verification_value?

        pairs
      end

      def add_encrypted_credit_card!(credit_card)
        pairs.swiped_ecr_host       = SWIPED_ECR_HOST
        pairs.enctrack2             = credit_card.track2
        pairs.encmp                 = credit_card.mp
        pairs.devicesn              = credit_card.device_sn
        pairs.mpstatus              = credit_card.mpstatus
        pairs.encryption_block_type = ENCRYPTION_BLOCK_TYPE
        pairs.registered_by         = REGISTERED_BY
        pairs.ksn                   = credit_card.ksn
        pairs.magtek_card_type      = MAGTEK_CARD_TYPE
      end

      def add_authorization!
        pairs.vendor   = @options[:login]
        pairs.partner  = @options[:partner]
        pairs.pwd      = @options[:password]
        pairs.user     = @options[:user].blank? ? @options[:user] : @options[:login]
      end

      def build_request_body
        add_authorization!

        pairs.to_h.map{|key, value|
          "#{key.to_s.upcase}[#{value.to_s.length}]=#{value}" 
        }.join("&")
      end
  end
end