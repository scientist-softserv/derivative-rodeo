# frozen_string_literal: true
require 'marcel'

module Derivative
  module Rodeo
    module Type
      class MimeType < BaseType
        self.prerequisites = [:original]

        # Given that we don't have a conventional derivative file, we need to see that it's
        # assigned.
        #
        # rubocop:disable Lint/UnusedMethodArgument
        def self.demand!(manifest:, storage:)
          manifest.mime_type
        end
        # rubocop:enable Lint/UnusedMethodArgument

        def generate
          content = arena.local_read(derivative: :original)
          arena.mime_type ||= ::Marcel::MimeType.for(content)

          # QUESTION: Should this be a method on the arena?
          Derivative::Rodeo::Arena
            .for_mime_type_processing(arena: arena)
            .start_processing!
        end
      end
    end
  end
end
