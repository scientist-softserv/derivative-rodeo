# frozen_string_literal: true
require 'hydra/file_characterization'

module Derivative
  module Rodeo
    module Step
      class FitsStep < BaseStep
        self.prerequisites = [:original]

        # @see https://github.com/samvera/hyrax/blob/426575a9065a5dd3b30f458f5589a0a705ad7be2/app/models/concerns/hyrax/file_set/characterization.rb#L20-L24
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
