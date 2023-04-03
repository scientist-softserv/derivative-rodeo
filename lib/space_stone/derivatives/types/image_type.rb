# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      class ImageType < BaseType
        self.prerequisites = []
        ##
        # @param repository [Repository]
        #
        # @raise [Exceptions::DerivativeNotFoundError] when we failed to generate the :image file.
        def generate_for(repository:); end
      end
    end
  end
end
