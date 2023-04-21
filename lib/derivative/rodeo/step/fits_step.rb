# frozen_string_literal: true

begin
  require 'hydra/file_characterization'
rescue LoadError
  puts "hydra/file_charaterization gem not found, no fits support"
  module Derivative
    module Rodeo
      module Step
        class FitsStep < BaseStep
          self.prerequisites = [:base_file_for_chain]

          # @see https://github.com/samvera/hyrax/blob/426575a9065a5dd3b30f458f5589a0a705ad7be2/app/models/concerns/hyrax/file_set/characterization.rb#L20-L24
          def generate
            # TODO: Leverage the path_for_shell_commands
            file_system_path = arena.local_path_for_shell_commands(derivative: :base_file_for_chain)
            content = File.read(file_system_path)
            filename = File.basename(arena.file_set_filename)

            arena.local_assign!(derivative: to_sym) do
              Hydra::FileCharacterization.characterize(content, filename, to_sym)
            end
          end
        end
      end
    end
  end
end
