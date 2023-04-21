# frozen_string_literal: true
require 'marcel'

module Derivative
  module Rodeo
    module Step
      ##
      #  This derivative is an inflection point.  We take the original file, determine it's mime
      #  step and from that launch into a new {Chain} of derivatives based on the {Configuration}.
      class MimeTypeStep < BaseStep
        self.prerequisites = [:base_file_for_chain]

        ##
        # @!group Configurations
        # @!attribute [rw]
        class_attribute :steps_by_media_type, default: { "image" => [:hocr] }

        ##
        # @!attribute [rw]
        class_attribute :steps_by_mime_type, default: { "application/pdf" => [:pdf_split] }

        ##
        # @!attribute [rw]
        class_attribute(:steps_by_sub_type, default: {})
        # @!endgroup Derivative Configurations

        ##
        # Given that we don't have a conventional derivative file, we need to see that it's
        # assigned.
        #
        # rubocop:disable Lint/UnusedMethodArgument
        def self.demand_path_for!(storage:)
          manifest = storage.manifest
          raise Exceptions::ManifestMissingMimeTypeError.new(manifest: manifest.mime_type) if manifest.mime_type.blank?
          coerce_to_mime_type(manifest.mime_type, manifest: manifest)
        end
        # rubocop:enable Lint/UnusedMethodArgument

        ##
        # @param mime_type [Symbol, String, MIME::Type]
        # @return [Array<Symbol>]
        # @see .coerce_to_mime_type
        def self.next_steps_for(mime_type:)
          mime_type = coerce_to_mime_type(mime_type)

          # Yes a bit of antics to ensure string or symbol keys; maybe not worth it.
          steps_by_media_type.fetch(mime_type.media_type, []) +
            steps_by_media_type.fetch(mime_type.media_type.to_sym, []) +

            steps_by_mime_type.fetch(mime_type.to_s, []) +
            steps_by_mime_type.fetch(mime_type.to_s.to_sym, []) +

            steps_by_sub_type.fetch(mime_type.sub_type, []) +
            steps_by_sub_type.fetch(mime_type.sub_type.to_sym, [])
        end

        ##
        # @param value [String, Symbol, MIME::Type]
        # @param manifest [NilClass, Derivative::Rodeo::Manifest] an optional parameter; if we have
        #        it, the error messaging will be more useful
        # @return [MIME::Type]
        def self.coerce_to_mime_type(value, manifest: nil)
          mime_type = case value
                      when String, Symbol
                        MIME::Types[value].first
                      when MIME::Type
                        value
                      end
          raise Exceptions::UnknownMimeTypeError.new(mime_type: value, manifest: manifest) if mime_type.blank?
          mime_type
        end

        def generate
          # TODO: Should we have a local_read?
          local_path = arena.local_path_for_shell_commands(derivative: :base_file_for_chain)
          content = File.read(local_path)
          arena.mime_type ||= ::Marcel::MimeType.for(content)
          mime_type = arena.local_demand_path_for!(derivative: to_sym)
          steps = self.class.next_steps_for(mime_type: mime_type)
          chain = Chain.new(derivatives: steps)
          Rodeo.process_derivative(json: arena.to_json(chain: chain, derivative_to_process: chain.first))
        end
      end
    end
  end
end
