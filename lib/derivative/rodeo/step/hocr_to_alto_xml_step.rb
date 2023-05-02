# frozen_string_literal: true

require 'derivative/rodeo/text_extractors/alto'
require 'derivative/rodeo/text_extractors/hocr'
require 'derivative/rodeo/utilities/image'

module Derivative
  module Rodeo
    module Step
      class HocrToAltoXmlStep < BaseStep
        self.prerequisites = [:base_file_for_chain, :hocr]

        # @see https://github.com/scientist-softserv/iiif_print/blob/83e37829a3830bc127e5d41a7d023489d4407498/lib/iiif_print/text_extraction/page_ocr.rb#L71-L74
        #
        # @todo
        # While we have the original image...should we just go ahead and capture the technical
        # metadata?  And send that as part of the manifest?  That would be some additional work.  Or
        # should we treat the technical metadata as a separate file?
        def generate
          hocr = TextExtractors::Hocr.new(hocr_path)
          technical_metadata = Utilities::Image.technical_metadata_for(path: base_file_for_chain_path)
          alto_xml = TextExtractors::Alto.to_alto(width: technical_metadata.width,
                                                  height: technical_metadata.height,
                                                  words: hocr.words)

          arena.local_assign!(derivative: to_sym) { alto_xml }
        end
      end
    end
  end
end
