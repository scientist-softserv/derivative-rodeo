# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Utilities
      ##
      # This module is responsible for extracting technical_metadata for a given path.
      #
      # @see {.technical_metadata_for}
      class ImageIdentify
        ##
        # @api public
        # @param path [String]
        # @return [SpaceStone::Derivatives::TechnicalMetadata]
        def self.technical_metadata_for(path:)
          new(path).technical_metadata
        end

        def initialize(path)
          @path = path
          # The first 23 characters of a file contains the magic.
          @initial_file_contents = File.read(@path, 23, 0)
        end
        attr_reader :path

        # Return metadata by means of imagemagick identify
        def technical_metadata
          # TODO: Utilities::Image.technical_metadata_for(path: path)
          technical_metadata = TechnicalMetadata.new
          lines = im_identify
          width, height = im_identify_geometry(lines)
          technical_metadata.width = width
          technical_metadata.height = height
          technical_metadata.content_type = im_mime(lines)
          populate_im_color!(lines, technical_metadata)
          technical_metadata
        end

        private

        # @return [Array<String>] lines of output from imagemagick `identify`
        def im_identify
          cmd = "identify -verbose #{path}"
          `#{cmd}`.lines
        end

        # @return [Array(Integer, Integer)] width, height in Integer px units
        def im_identify_geometry(lines)
          img_geo = im_line_select(lines, 'geometry').split('+')[0]
          img_geo.split('x').map(&:to_i)
        end

        def im_mime(lines)
          return 'application/pdf' if pdf? # workaround older imagemagick bug
          im_line_select(lines, 'mime type')
        end

        def pdf?
          @initial_file_contents.start_with?('%PDF-')
        end

        def populate_im_color!(lines, technical_metadata)
          bpc = im_line_select(lines, 'depth').split('-')[0].to_i # '1-bit' -> 1
          colorspace = im_line_select(lines, 'colorspace')
          color = colorspace == 'Gray' ? 'gray' : 'color'
          has_alpha = !im_line_select(lines, 'Alpha').nil?
          technical_metadata.num_components = (color == 'gray' ? 1 : 3) + (has_alpha ? 1 : 0)
          technical_metadata.color = bpc == 1 ? 'monochrome' : color
          technical_metadata.bits_per_component = bpc
        end

        def im_line_select(lines, key)
          line = lines.find { |l| l.scrub.downcase.strip.start_with?(key) }
          # Given "key: value" line, return the value as String stripped of
          #   leading and trailing whitespace
          return line if line.nil?
          line.strip.split(':')[-1].strip
        end
      end
    end
  end
end
