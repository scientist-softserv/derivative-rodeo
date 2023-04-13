# frozen_string_literal: true
require 'hydra/file_characterization'

module Derivative
  module Rodeo
    module Step
      class FitsStep < BaseStep
        self.prerequisites = [:original]

        def generate
          content = arena.local_read(derivative: :original)
          filename = File.basename(arena.original_filename)

          arena.local_assign!(derivative: to_sym) do
            Hydra::FileCharacterization.characterize(content, filename, to_sym)
          end
        end
      end
    end
  end
end
