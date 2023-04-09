# frozen_string_literal: true

module Derivative
  module Rodeo
    # A simple data structure that summarizes the image properties of the given path.
    #
    # @see Derivative::Rodeo::ImagePropertiesExtractor
    PdfPagesSummary = Struct.new(
      :path, :page_count, :width,
      :height, :pixels_per_inch, :color_description,
      :channels, :bits_per_channel, keyword_init: true
    ) do
      # @return [Array<String, Integer, Integer>]
      def color
        [color_description, channels, bits_per_channel]
      end
      alias_method :ppi, :pixels_per_inch
      alias_method :bits, :bits_per_channel

      # If the underlying extraction couldn't set the various properties, we likely have an
      # invalid_pdf.
      def valid?
        return false if pdf_pages_summary.color_description.nil?
        return false if pdf_pages_summary.channels.nil?
        return false if pdf_pages_summary.bits_per_channel.nil?
        return false if pdf_pages_summary.height.nil?
        return false if pdf_pages_summary.page_count.to_i.zero?

        true
      end
    end

    # I want to ensure the struct is created first so that I don't have collisions on name space.
    require 'derivative/rodeo/pdf_pages_summary/extractor'

    ##
    # @api public
    #
    # @param path [String]
    # @param extractor [#call, Derivative::Rodeo::PdfPagesSummary::Extractor]
    # @return [Derivative::Rodeo::PdfPagesSummary]
    #
    # @note This looks a bit funny because I want to allow for dependency injection of the given
    #       extractor.  And to do that correctly, I need to first establish the Struct, then require
    #       the extractor then add this singleton method.
    def PdfPagesSummary.extract(path:, extractor: PdfPagesSummary::Extractor)
      extractor.call(path)
    end
  end
end
