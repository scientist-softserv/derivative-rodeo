# frozen_string_literal: true

module Derivative
  module Rodeo
    module Step
      class MonochromeStep < BaseStep
        self.prerequisites = [:original]

        def generate
          original_path = arena.local_demand_path_for!(derivative: :original)

          image = Derivative::Rodeo::Utilities::Image.new(original_path)

          if image.monochrome?
            monochrome_path = original_path
          else
            monochrome_path = arena.local_path(derivative: to_sym, filename: 'monochrome-interim.tif')

            # Convert the above image to a file at the monochrome_path
            image.convert(monochrome_path, true)
          end

          arena.local_assign!(derivative: to_sym, path: monochrome_path)
        end
      end
    end
  end
end
