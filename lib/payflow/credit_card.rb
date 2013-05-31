require 'active_model'

module Payflow
  class CreditCard
    include ActiveModel::Validations
    validates_with CreditCardValidator

    attr_accessor :number
    attr_accessor :month
    attr_accessor :year
    attr_accessor :brand
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :security_code
    attr_accessor :encrypted_track_data
    attr_accessor :last_four_digits

    attr_accessor :track2
    attr_accessor :mp
    attr_accessor :ksn
    attr_accessor :mpstatus
    attr_accessor :device_sn


    def initialize(options = {})
      @number = options[:number]
      @month  = options[:month]
      @year   = options[:year]
      @first_name = options[:first_name]
      @last_name  = options[:last_name]
      @encrypted_track_data = options[:encrypted_track_data]

      self.track2    = options[:track2]
      self.mpstatus  = options[:mpstatus]
      self.device_sn = options[:device_sn]
      self.ksn       = options[:ksn]
      self.mp        = options[:mp]

      parse_encryption if encrypted?
    end

    def expiry_date
      ExpiryDate.new(@month, @year)
    end

    def expired?
      expiry_date.expired?
    end

    def encrypted?
      encrypted_track_data.present?
    end

    def display_number
      self.class.mask(number)
    end

    def name
      "#{first_name} #{last_name}"
    end

    def last_four
      self.class.last_digits(number)
    end

    def self.mask(number)
      "XXXX-XXXX-XXXX-#{last_digits(number)}"
    end

    def self.last_digits(number)
      number.to_s.length <= 4 ? number : number.to_s.slice(-4..-1)
    end

    private
      def parse_encryption
      end

  end
end