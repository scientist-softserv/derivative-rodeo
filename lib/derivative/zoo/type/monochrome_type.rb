# frozen_string_literal: true

module Derivative
  module Zoo
    module Type
      class MonochromeType < BaseType
        self.prerequisites = [:original]

        def generate
          original_path = environment.local_demand!(derivative: :original)

          image = Derivative::Zoo::Utilities::Image.new(original_path)

          if image.monochrome?
            monochrome_path = original_path
          else
            monochrome_path = environment.local_path(derivative: to_sym, filename: 'monochrome-interim.tif')

            # Convert the above image to a file at the monochrome_path
            image.convert(monochrome_path, true)
          end

          environment.local_assign!(derivative: to_sym, path: monochrome_path)
        end
      end
    end
  end
end
