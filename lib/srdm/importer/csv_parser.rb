require 'csv'

module SRDM
  module Importer
    class CSVParser
      attr_reader :file

      def initialize(file, headers: true, encoding: 'BOM|UTF-8:UTF-8')
        @file = file
        @headers = headers
        @encoding = encoding
        read_csv
      end

      def method_missing(meth, *args, &blk)
        @csv.send(meth, *args, &blk)
      end

      private

      def read_csv
        @csv = CSV.read(@file, headers: @headers, encoding: @encoding)
      end
    end
  end
end
