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

          # TODO: Revisit this setup; also consider how to enqueue this; Because, as written this
          # will call things inline.
          chain = Chain.from_mime_types_for(manifest: arena.manifest, config: arena.config)
          Rodeo.invoke_with(json: arena.to_json(chain: chain, derivative_to_process: chain.first))
        end
      end
    end
  end
end
