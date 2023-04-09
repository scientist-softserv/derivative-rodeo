# frozen_string_literal: true

module Derivative
  module Rodeo
    module PageSplitters
      # The purpose of this class is to split the PDF into constituent jpg files.
      class Jpg < PageSplitters::Base
        self.image_extension = 'jpg'
        self.quality = '50'
        self.gsdevice = 'jpeg'
      end
    end
  end
end
