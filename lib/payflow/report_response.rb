require 'nokogiri'
module Payflow
  class ReportResponse
    attr_accessor :result, :report_id, :status_code

    def initialize(http_response)
      @http_response = http_response
      @result = parse(http_response.body)
    end

    def successful?
      response_successful? && @status_code == 3
    end

    def message
      successful? ? @status_message : @response_message
    end

    def response_successful?
      @response_code == 100
    end

    private

      def parse(xml)
        doc = Nokogiri::XML(xml)

        doc.xpath("//responseCode").each do |row|
          @response_code = row.text.to_i
        end
        doc.xpath("//reportId").each do |row|
          @report_id = row.text  
        end
        doc.xpath("//statusMsg").each do |row|
          @status_message = row.text  
        end
        doc.xpath("//responseMsg").each do |row|
          @response_message = row.text  
        end
        doc.xpath("//statusCode").each do |row|
          @status_code = row.text.to_i
        end
      end
  end
end