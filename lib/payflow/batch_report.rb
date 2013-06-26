module Payflow
  class BatchReport < Report
    def create_report(processor, start_date, end_date)
      xml = Builder::XmlMarkup.new
      xml.tag! 'runReportRequest' do
        xml.tag! 'reportName', 'BatchIDReport'

        [
          {name: 'processor', value: processor},
          {name: 'start_date', value: date_string(start_date)},
          {name: 'end_date', value: date_string(end_date)}
        ].each do |param|
          xml.tag! 'reportParam' do
            xml.tag! 'paramName', param[:name]
            xml.tag! 'paramValue', param[:value]
          end
        end
      end

      response = commit(xml.target!)
      @report_id = response.report_id if response.successful?
      response
    end
  end
end