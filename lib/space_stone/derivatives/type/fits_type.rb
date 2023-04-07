# frozen_string_literal: true
require 'marcel'
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

          environment.mime_type ||= ::Marcel::MimeType.for(content)

          environment.local_path(derivative: :original)
        end
      end
    end
  end
end
