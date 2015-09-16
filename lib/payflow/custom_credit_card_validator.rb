require 'active_model'
require 'credit_card_validator'

module Payflow
  class CreditCard
    class CustomCreditCardValidator < ActiveModel::Validator
      attr_accessor :record
      
      def validate(record)
        @record = record
        validate_card_number
        validate_card_brand
      end

      def validate_card_number
        if record.number.blank?
          record.errors.add :number, "is required"
        elsif CreditCardValidator::Validator.valid?(number)
          record.errors.add :number, "is not a valid credit card number"
        elsif type_match?(number, brand)
          record.errors.add :brand, "does not match the card number"
        end
      end

      def validate_card_brand
        record.errors.add :brand, "is required" if record.brand.blank? && record.number.present?
        record.errors.add :brand, "is invalid"  unless record.brand.blank? || CreditCardValidator.CARD_TYPES.keys.include?(brand)
      end

      def type_match?(number, brand)
        CreditCardValidator::Validator.card_type(number) == match
      end
    end
  end
end