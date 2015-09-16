module Payflow
  class TransactionSearch < Report
    def create_search(transaction_id)
      xml = Builder::XmlMarkup.new
      xml.tag! 'runSearchRequest' do
        xml.tag! 'searchName', 'TransactionIDSearch'
        [
          {name: 'transaction_id', value: transaction_id}

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