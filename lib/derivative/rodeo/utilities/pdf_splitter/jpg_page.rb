# frozen_string_literal: true

module Derivative
  module Rodeo
    module Utilities
      module PdfSplitter
        # The purpose of this class is to split the PDF into constituent jpg files.
        class JpgPage < PdfSplitter::Base
          self.image_extension = 'jpg'
          self.quality = '50'
          self.gsdevice = 'jpeg'
        end
      end
    end
  end
end
