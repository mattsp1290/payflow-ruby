require 'builder'
require 'nokogiri'

module Payflow
  class Report

    attr_accessor :xml, :login, :password, :partner, :user, :report_id
    
    TEST_HOST = 'payments-reports.paypal.com/test-reportingengine'
    LIVE_HOST = 'payments-reports.paypal.com/reportingengine'

    def initialize(merchant_account, options = {})
      @options = options
      @login = merchant_account.login
      @partner = merchant_account.partner
      @password = merchant_account.password
      @user = merchant_account.user || merchant_account.login
      @options = options.merge({
        login: login,
        password: password,
        partner: partner,
        user: user
      })
    end

    def create_report
      raise NotImplementedError
    end

    def fetch(id = nil)
      id ||= self.report_id
      meta = get_meta(id)
      if meta.successful?
        meta = parse_meta(meta.body)
        data = parse_data(meta, get_data(id).body)
      else
        puts meta.inspect
        nil
      end
    end

    def commit(body)
      body = build_request(body)

      response = connection.post do |request|
        request.body = body
      end

      Payflow::ReportResponse.new(response)
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

      def get_meta(report_id)
        xml = Builder::XmlMarkup.new
        xml.tag! 'getMetaDataRequest' do
          xml.tag! 'reportId', report_id
        end

        commit(xml.target!)
      end

      def get_data(report_id)
        xml = Builder::XmlMarkup.new
        xml.tag! 'getDataRequest' do
          xml.tag! 'reportId', report_id
          xml.tag! 'pageNum', "1"
        end

        commit(xml.target!)
      end

      def parse_meta(xml)
        doc = Nokogiri::XML(xml)

        columns = []
        doc.xpath("//columnMetaData").each do |node|
          columns << node.xpath(".//dataName").text
        end

        {
          responseCode: doc.xpath("//responseCode").text,
          numberOfPages: doc.xpath("//numberOfPages").text,
          perPage: doc.xpath("//pageSize").text,
          columns: columns
        }
      end

      def date_string(date)
        date = date.to_s unless date.is_a?(String)
        date
      end

      def parse_data(meta, xml)
        doc = Nokogiri::XML(xml)

        report = []
        doc.xpath("//reportDataRow").each do |row|
          row_data = {}
          row.xpath(".//columnData").each do |column|
            column_number = column.attr("colNum").to_i - 1
            row_data[meta[:columns][column_number]] = column.xpath(".//data").text
          end
          report << row_data
        end

        report
      end
  end
end