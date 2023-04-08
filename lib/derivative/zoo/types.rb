# frozen_string_literal: true

module Derivative
  module Zoo
    module Types
      ##
      # @api public
      #
      # @param manifest [Derivative::Zoo::Manifest]
      #
      # @return [Array<Symbol>] a list of named derivatives that should be generated for the given
      #         :manifest.
      def self.for(manifest:, config: Zoo.config)
        raise Exceptions::ManifestMissingMimeTypeError.new(manifest: manifest) if manifest.mime_type.blank?

        mime_type =
          case manifest.mime_type
          when String, Symbol
            MIME::Types[manifest.mime_type].first
          when MIME::Type
            manifest.mime_type
          end

        raise Exceptions::UnknownMimeTypeError.new(manifest: manifest, mime_type: mime_type) if mime_type.nil?

        config.derivatives_for(mime_type: mime_type)
      end
    end
  end
end
