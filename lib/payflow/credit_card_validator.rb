require 'active_model'

module Payflow
  class CreditCard
    class CreditCardValidator < ActiveModel::Validator
      CARD_TYPES = {
        :visa => /^4[0-9]{12}(?:[0-9]{3})?$/,
        :master => /^5[1-5][0-9]{14}$/,
        :maestro => /(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
        :diners_club => /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
        :amex => /^3[47][0-9]{13}$/,
        :discover => /^6(?:011|5[0-9]{2})[0-9]{12}$/,
        :jcb => /^(?:2131|1800|35\d{3})\d{11}$/
      }

      attr_accessor :record

      def self.brand(number)
        CARD_TYPES.keys.each do |t|
          return t if card_is?(t, number)
        end
        nil
      end

      def validate(record)
        @record = record
        validate_card_number
      end

      def validate_card_number
        if record.number.blank?
          record.errors.add :number, "is required"
        elsif !CreditCard.valid_number?(number)
          record.errors.add :number, "is not a valid credit card number"
        elsif !CreditCard.matching_brand?(number, brand)
          record.errors.add :brand, "does not match the card number"
        end
      end

      def validate_card_brand #:nodoc:
        record.errors.add :brand, "is required" if record.brand.blank? && record.number.present?
        record.errors.add :brand, "is invalid"  unless record.brand.blank? || CreditCard.card_companies.keys.include?(brand)
      end

      protected
        def self.card_is?(type, number)
          type = type.to_sym
          (CARD_TYPES[type] and strip(number) =~ CARD_TYPES[type])
        end

        def self.strip(number)
          number.gsub(/\s/,'')
        end
    end
  end
end