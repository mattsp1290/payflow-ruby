module Payflow
  class BatchSearch < Report
    #Start Date and End Date MUST include H:M:S, ex) 2014-01-01 00:00:00
    def create_search(batch_id, start_date, end_date, page_size = '350')
      xml = Builder::XmlMarkup.new
      xml.tag! 'runSearchRequest' do
        xml.tag! 'searchName', 'BatchIDSearch'
        [
          {name: 'batch_id', value: batch_id},
          {name: 'start_date', value: date_string(start_date)},
          {name: 'end_date', value: date_string(end_date)}
        ].each do |param|
          xml.tag! 'reportParam' do
            xml.tag! 'paramName', param[:name]
            xml.tag! 'paramValue', param[:value]
          end
        end
        xml.tag! 'pageSize', page_size
      end

      response = commit(xml.target!)
      @report_id = response.report_id if response.successful?
      response
    end

  end
end