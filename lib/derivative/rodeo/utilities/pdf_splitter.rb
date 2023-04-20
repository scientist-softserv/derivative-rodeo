# frozen_string_literal: true

module Derivative
  module Rodeo
    module Utilities
      module PdfSplitter
        ##
        # @api public
        #
        # Find the {PdfSplitter::Base} with the given name.
        #
        # @param name [#to_s]
        # @return [PdfSplitter::Base]
        def self.for(name)
          klass_name = "#{name.to_s.classify}_page".classify
          "Derivative::Rodeo::Utilities::PdfSplitter::#{klass_name}".constantize
        end
      end
    end
  end
end

require 'derivative/rodeo/utilities/pdf_splitter/base'
require 'derivative/rodeo/utilities/pdf_splitter/jpg_page'
require 'derivative/rodeo/utilities/pdf_splitter/png_page'
require 'derivative/rodeo/utilities/pdf_splitter/tiff_page'
