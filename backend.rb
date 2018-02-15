#!/usr/bin/ruby

require 'marc'
require 'http'

# we make HTTP::Body's readpartial also accessible as read so that the XMLReader can talk to it directly
module HTTP
  class Response
    class Body
      def read
        readpartial
      end
    end
  end
end

module TelnetOPAC
  class Backend
    def initialize(host, port)
      @host = host
      @port = port
    end

    def biblio_search(search, type = :all)
      query = search
      case type
        when :title
          query = "title=#{search}"
      end
    
      query_params = {
        :version => 1.1,
        :operation => 'searchRetrieve',
        :query => query,
        :startRecord => 1,
        :maximumRecords => 10,
        :recordSchema => 'marcxml'
      }
      http_response = HTTP.get("http://#{@host}:#{@port}/biblios?#{HTTP::URI.form_encode query_params}")
      reader = MARC::XMLReader.new(http_response.body)
    
      response = Array.new
      for marc_record in reader
        record = {
          :biblio_id => marc_record['999']['c'],
          :title => marc_record['245']['a'],
          :subtitle =>  marc_record['245']['b'],
          :author => marc_record['245']['c'],
        }
        record[:author_dates] = marc_record['100']['d'] if marc_record['100']
        record[:publication_date] = marc_record['260']['c'] if marc_record['260']
        record[:publication_date] = marc_record['264']['c'] if marc_record['264'] and !record[:publication_date]
        if(marc_record['952'])
          record[:holdings] = Array.new
          # TODO: support more than one holding for the same bib
          holding = Hash.new
          holding[:home_branch] = marc_record['952']['a']
          holding[:current_branch] = marc_record['952']['b']
          holding[:location] = marc_record['952']['c']
          holding[:call_number] = marc_record['952']['o']
          holding[:checkout_date] = marc_record['952']['q'] if marc_record['952']['q']
          record[:holdings][0] = holding
        end
        response.push record
      end
      response
    end
  end
end
