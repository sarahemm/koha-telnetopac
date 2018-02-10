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
          :title => marc_record['245']['a'],
          :subtitle =>  marc_record['245']['b'],
          :author => marc_record['245']['c'],
        }
        response.push record
      end
      response
    end
  end
end
