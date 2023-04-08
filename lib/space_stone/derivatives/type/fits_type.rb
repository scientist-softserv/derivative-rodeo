# frozen_string_literal: true
require 'hydra/file_characterization'

module SpaceStone
  module Derivatives
    module Type
      class FitsType < BaseType
        self.prerequisites = [:original]

        def generate
          content = environment.local_read(derivative: :original)
          filename = File.basename(environment.original_filename)

          environment.local_assign!(derivative: to_sym) do
            Hydra::FileCharacterization.characterize(content, filename, to_sym)
          end
        end
      end
    end
  end
end
