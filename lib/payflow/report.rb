require 'builder'

module Payflow
  class Report

    attr_accessor :xml
    
    TEST_HOST = 'payments-reports.paypal.com/test-reportingengine'
    LIVE_HOST = 'payments-reports.paypal.com/reportingengine'

    def initialize
    end

    def run_report()
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.tag! 'reportName', 'DailyActivityReport'
      xml.tag! 'reportParam' do
        xml.tag! 'paramName', 'report_date'
        xml.tag! 'paramValue', '2013-06-03'
      end

      commit(xml.target!)
    end

    def commit(body)
      body = build_request(body)
      response = connection.post do |request|
        add_common_headers!(request)
        request.body = body
      end

      puts response.inspect
    end

    def test?
      true
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

      def build_request(body)
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.tag! 'reportingEngineRequest', 'Timeout' => timeout.to_s, 'version' => "2.1", "xmlns" => XMLNS do
          xml.tag! 'authRequest' do
            xml.tag! 'user', !@options[:user].blank? ? @options[:user] : @options[:login]
            xml.tag! 'password', @options[:password]
            xml.tag! 'vendor', @options[:login]
            xml.tag! 'partner', @options[:partner]
          end

          xml.tag! 'runReportRequest' do
            xml << body
          end
        end
        xml.target!
      end
  end
end