# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      class MonochromeType < BaseType
        self.prerequisites = [:image]

        def generate
          image_path = environment.local_demand!(derivative: :image)

          image = SpaceStone::Derivatives::Utilities::Image.new(image_path)

          if image.monochrome?
            monochrome_path = image_path
          else
            monochrome_path = environment.local_path(derivative: to_sym, filename: 'monochrome-interim.tif')
            image.convert(monochrome_path, true)
          end

          environment.local_assign!(derivative: to_sym, path: monochrome_path)
        end
      end
    end
  end
end
