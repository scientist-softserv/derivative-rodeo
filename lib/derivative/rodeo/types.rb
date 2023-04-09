# frozen_string_literal: true

module Derivative
  module Rodeo
    module Types
      ##
      # @api public
      #
      # @param manifest [Derivative::Rodeo::Manifest]
      #
      # @return [Array<Symbol>] a list of named derivatives that should be generated for the given
      #         :manifest.
      def self.for(manifest:, config: Rodeo.config)
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
