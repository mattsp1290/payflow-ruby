require 'nokogiri'

module Payflow
  class Response
    attr_accessor :result

    def initialize(http_response)
      puts "-----------------------"
      puts http_response.inspect
      puts "-----------------------"
      @http_response = http_response
      @result = parse(http_response)
    end

    def successful?
      result[:result] == "0"
    end

    def message
      result[:message]
    end

    def authorization_token
      result[:pn_ref] || @result[:rp_ref]
    end

    def avs_result
      result[:avs_result]
    end

    def cvv_result
      result[:cv_result]
    end

    private

      def parse(http_response)
        response = {}
        xml = Nokogiri::XML(http_response.body)
        xml.remove_namespaces!

        root = xml.xpath("//ResponseData")
        tx_result = root.xpath(".//TransactionResult").first

        tx_result.xpath(".//*").each do |node|
          parse_element(response, node)
        end

        response
      end

      def parse_element(response, node)
        response[node.name.underscore.to_sym] = node.text
      end
  end
end