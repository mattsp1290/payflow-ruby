require 'faraday'

module Payflow

  CARD_MAPPING = {
    :visa => 0,
    :master => 1,
    :discover => 2,
    :american_express => 3,
    :jcb => 5,
    :diners_club => 4
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
      self.pairs   = initial_pairs(action, money, options[:pairs])
      
      case action
      when :sale, :authorization
        build_sale_or_authorization_request(action, money, credit_card_or_reference, options)
      when :capture
        build_reference_request(action, money, credit_card_or_reference, options)
      when :void
        build_reference_request(action, money, credit_card_or_reference, options)
      when :credit
        build_reference_request(action, money, credit_card_or_reference, options)
      end
    end

    def build_sale_or_authorization_request(action, money, credit_card_or_reference, options)
      if credit_card_or_reference.is_a?(String)
        build_reference_request(action, money, credit_card_or_reference, options)
      else
        build_credit_card_request(action, money, credit_card_or_reference, options)
      end
    end

    def build_credit_card_request(action, money, credit_card, options)
      pairs.tender = CREDIT_CARD_TENDER
      add_credit_card!(credit_card)
    end

    def build_reference_request(action, money, authorization, options)
      pairs.tender = CREDIT_CARD_TENDER
      pairs.origid = authorization
    end

    def add_credit_card!(credit_card)
      pairs.card_type = credit_card_type(credit_card)

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
      year  = sprintf("%.2i", creditcard.year.to_s.sub(/^0+/, '')).slice(-2, 2)
      month = sprintf("%.2i", creditcard.month.to_s.sub(/^0+/, ''))

      "#{month}#{year}"
    rescue ArgumentError
      ""
    end

    def commit(options = {})
      nvp_body = build_request_body
      
      return Payflow::MockResponse.new(nvp_body) if @options[:mock]

      response = connection.post do |request|
        add_common_headers!(request)
        request.headers["X-VPS-REQUEST-ID"] = options[:order_id] || SecureRandom.base64(20)
        request.body = nvp_body
      end

      Payflow::Response.new(response)
    end

    def test?
      @options[:test] == true
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

      def add_common_headers!(request)
        request.headers["Content-Type"] = "text/name value"
        request.headers["X-VPS-CLIENT-TIMEOUT"] = TIMEOUT.to_s
        request.headers["X-VPS-VIT-Integration-Product"] = "Payflow Gem"
        request.headers["X-VPS-VIT-Runtime-Version"] = RUBY_VERSION
        request.headers["Host"] = test? ? TEST_HOST : LIVE_HOST
      end

      def initial_pairs(action, money, optional_pairs = {})
        struct = OpenStruct.new(
          trxtype: TRANSACTIONS[action]
        )
        struct.amt = money if money and money.to_f > 0
        if optional_pairs
          optional_pairs.each do |key, value|
            struct[key] = value
          end
        end
        struct
      end

      def add_keyed_credit_card!(credit_card)
        pairs.acct    = credit_card.number
        pairs.expdate = expdate(credit_card)
        pairs.cvv2    = credit_card.security_code if credit_card.security_code.present?

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
        pairs.user     = @options[:user].blank? ? @options[:login] : @options[:user]
      end

      def build_request_body
        add_authorization!

        pairs.marshal_dump.map{|key, value|
          "#{key.to_s.upcase.gsub("_", "")}[#{value.to_s.length}]=#{value}" 
        }.join("&")
      end
  end
end