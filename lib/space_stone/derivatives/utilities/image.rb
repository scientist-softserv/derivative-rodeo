# frozen_string_literal: true

require 'open3'
require 'tmpdir'

module SpaceStone
  module Derivatives
    module Utilities
      class Image
        attr_accessor :path

        def initialize(path)
          @path = path
          # The first 23 characters of a file contains the magic.
          @initial_file_contents = File.read(@path, 23, 0)
        end

        def jp2?
          @initial_file_contents.end_with?('ftypjp2')
        end

        def pdf?
          @initial_file_contents.start_with?('%PDF-')
        end

        # @return [SpaceStone::Derivatives::TechnicalMetadata]
        def metadata
          return @metadata if defined?(@metadata)

          @metadata = jp2? ? jp2_metadata : identify_metadata
        end

        # Convert source image to image at destination path, inferring file type from destination
        # file extension.  In case of JP2 files, create intermediate file using OpenJPEG 2000 that
        # ImageMagick can use.  Only outputs monochrome output if monochrome is true, destination
        # format is TIFF.
        #
        # @param destination [String] Path to output / destination file
        # @param monochrome [Boolean] true if monochrome output, otherwise false
        def convert(destination, monochrome = false)
          raise 'JP2 output not yet supported' if destination.end_with?('jp2')
          return convert_image(jp2_to_tiff(@path), destination, monochrome) if jp2?
          convert_image(@path, destination, monochrome)
        end

        private

        def convert_image(source, destination, monochrome)
          monochrome &&= destination.slice(-4, 4).index('tif')
          mono_opts = "-depth 1 -monochrome -compress Group4 -type bilevel "
          opts = monochrome ? mono_opts : ''
          cmd = "convert #{source} #{opts}#{destination}"
          `#{cmd}`
        end

        def jp2_to_tiff(source)
          intermediate_path = File.join(Dir.mktmpdir, 'intermediate.tif')
          jp2_cmd = "opj_decompress -i #{source} -o #{intermediate_path}"
          `#{jp2_cmd}`
          intermediate_path
        end

        def jp2_metadata
          Utilities::ImageJp2.technical_metadata_for(path: path)
        end

        # Return metadata by means of imagemagick identify
        def identify_metadata
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
