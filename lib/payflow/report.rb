require 'builder'

module Payflow
  class Report

    attr_accessor :xml
    
    TEST_HOST = 'payments-reports.paypal.com/test-reportingengine'
    LIVE_HOST = 'payments-reports.paypal.com/reportingengine'

    def initialize(options)
      @options = options
    end

    def settlement_report(processor)
      xml = Builder::XmlMarkup.new
      xml.tag! 'runReportRequest' do
        xml.tag! 'reportName', 'SettlementReport'

        [
          {name: 'processor', value: processor},
          {name: 'start_date', value: '2013-05-03'},
          {name: 'end_date', value: '2013-06-03'}
        ].each do |param|
          xml.tag! 'reportParam' do
            xml.tag! 'paramName', param[:name]
            xml.tag! 'paramValue', param[:value]
          end
        end
      end

      commit(xml.target!)
    end

    def get_meta(report_id)
      xml = Builder::XmlMarkup.new
      xml.tag! 'getMetaDataRequest' do
        xml.tag! 'reportId', report_id
      end

      commit(xml.target!)
    end

    def get_report(report_id)
      xml = Builder::XmlMarkup.new
      xml.tag! 'getDataRequest' do
        xml.tag! 'reportId', report_id
        xml.tag! 'pageNum', "1"
      end

      commit(xml.target!)
    end

    def commit(body)
      body = build_request(body)

      puts body

      response = connection.post do |request|
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
        xml.tag! 'reportingEngineRequest' do
          xml.tag! 'authRequest' do
            xml.tag! 'user', !@options[:user].blank? ? @options[:user] : @options[:login]
            xml.tag! 'vendor', @options[:login]
            xml.tag! 'partner', @options[:partner]
            xml.tag! 'password', @options[:password]
          end

          xml << body
        end
        xml.target!
      end
  end
end