# frozen_string_literal: true

module SpaceStone
  module PdfSplitter
    # A simple data structure that summarizes the image properties of the given path.
    #
    # @see SpaceStone::PdfSplitter::ImagePropertiesExtractor
    PdfPagesSummary = Struct.new(
      :path, :page_count, :width,
      :height, :pixels_per_inch, :color_description,
      :channels, :bits, keyword_init: true
    ) do
      # return [Array<String, Integer, Integer>]
      def color
        [color_description, channels, bits]
      end
      alias_method :ppi, :pixels_per_inch
    end

    # I want to ensure the struct is created first so that I don't have collisions on name space.
    require 'space_stone/pdf_splitter/pdf_pages_summary/extractor'

    ##
    # @api public
    #
    # @param path [String]
    # @param extractor [#call, SpaceStone::PdfSplitter::PdfPagesSummary::Extractor]
    # @return [SpaceStone::PdfSplitter::PdfPagesSummary]
    #
    # @note This looks a bit funny because I want to allow for dependency injection of the given
    #       extractor.  And to do that correctly, I need to first establish the Struct, then require
    #       the extractor then add this singleton method.
    def PdfPagesSummary.extract(path:, extractor: PdfPagesSummary::Extractor)
      extractor.call(path)
    end
  end
end
