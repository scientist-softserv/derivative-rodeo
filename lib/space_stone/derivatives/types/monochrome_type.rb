# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      class MonochromeType < BaseType
        self.prerequisites = [:image]
        ##
        # @param repository [SpaceStone::Derivatives::Repository]
        def generate_for(repository:)
          image_path = repository.demand_local_for!(derivative: :image)

          image = SpaceStone::Derivatives::Utilities::Image.new(image_path)

          if image.monochrome?
            monochrome_path = image_path
          else
            monochrome_path = repository.local_path(derivative: to_sym, filename: 'monochrome-interim.tif')
            image.convert(monochrome_path, true)
          end

          repository.local_assign(derivative: to_sym, path: monochrome_path)

          repository.demand_local_for!(derivative: to_sym)
        end
      end
    end
  end
end
