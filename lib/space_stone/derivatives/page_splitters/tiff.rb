# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module PageSplitters
      # The purpose of this class is to split the PDF into constituent tiff files.
      class Tiff < PageSplitters::Base
        self.image_extension = 'tiff'
        self.compression = 'lzw'

        ##
        # @api private
        #
        # @return [String]
        def gsdevice
          return @gsdevice if defined?(@gsdevice)

          color = pdf_pages_summary.color_description
          channels = pdf_pages_summary.channels
          bpc = pdf_pages_summary.bits_per_channel

          if color == 'gray'
            # CCITT Group 4 Black and White, if applicable:
            if bpc == 1
              self.compression = 'g4'
              return @gsdevice = 'tiffg4'
            elsif bpc > 1
              # 8 Bit Grayscale, if applicable:
              return @gsdevice = 'tiffgray'
            end
          end

          # otherwise color:
          @gsdevice = colordevice(channels, bpc)
        end

        def colordevice(channels, bpc)
          bits = bpc * channels
          # will be either 8bpc/16bpd color TIFF,
          #   with any CMYK source transformed to 8bpc RBG
          bits = 24 unless [24, 48].include? bits
          "tiff#{bits}nc"
        end
      end
    end
  end
end
