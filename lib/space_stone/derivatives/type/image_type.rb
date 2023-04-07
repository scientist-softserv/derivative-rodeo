# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Type
      class ImageType < BaseType
        self.prerequisites = []
        ##
        # @raise [Exceptions::DerivativeNotFoundError] when we failed to generate the :image file.
        def generate; end
      end
    end
  end
end
