# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Strategies
      # The purpose of this class is to split the PDF into constituent jpg files.
      class Jpg < Strategies::Base
        self.image_extension = 'jpg'
        self.quality = '50'
        self.gsdevice = 'jpeg'
      end
    end
  end
end
