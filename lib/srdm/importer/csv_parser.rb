require 'csv'

module SRDM
  module Importer
    class CSVParser
      attr_reader :file

      def initialize(file, headers: true, encoding: 'BOM|UTF-8:UTF-8', header_mapping: nil)
        @file = file
        @headers = headers
        @encoding = encoding
        @header_mapping = header_mapping
        read_csv
      end

      def method_missing(meth, *args, &blk)
        @csv.send(meth, *args, &blk)
      end

      private

      def header_lambda
        lambda do |header, field_info|
          @header_mapping[header] || header
        end
      end

      def read_csv
        if @header_mapping
          @csv = CSV.read( @file, headers: true, header_converters: header_lambda)
        else
          @csv = CSV.read(@file, headers: @headers, encoding: @encoding)
        end
      end
    end
  end
end
