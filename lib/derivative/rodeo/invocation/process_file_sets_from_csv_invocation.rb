# frozen_string_literal: true

module Derivative
  module Rodeo
    module Invocation
      ##
      # Responsible for converting each of the given CSV's rows into a {Manifest} and then
      # enqueueing them for the rodeo.
      #
      # @note The CSV Format is assumed to have the following headers:
      #
      # - parent_identifier
      # - original_filename
      # - path_to_original
      # - mime_type
      #
      # All other columns will treated as the keys for the derivatives array on a manifest.
      #
      #
      # @see REQUIRED_COLUMN_NAMES
      class ProcessFileSetsFromCsvInvocation
        include Invocation::Base

        class_attribute(
          :csv_parse_options,
          default: { headers: true, encoding: 'utf-8' }
        )

        class_attribute(:derivative_to_process, default: :original)

        def call
          # For assistance in debugging.
          CSV.parse(body, **csv_parse_options) do |row|
            manifest = self.class.convert_to_manifest(row: row)
            arena = arena_for(manifest: manifest)
            enqueue(arena: arena)
          end
        end

        REQUIRED_COLUMN_NAMES = [:parent_identifier, :original_filename, :path_to_original, :mime_type].freeze

        # @param row [#to_hash]
        #
        # @return [Derivative::Rodeo::Manifest::PreProcess]
        def self.convert_to_manifest(row:)
          hash = row.to_hash.symbolize_keys
          kwargs = hash.slice(*REQUIRED_COLUMN_NAMES)
          derivatives = hash.except(*REQUIRED_COLUMN_NAMES)
          kwargs[:derivatives] = derivatives
          Rodeo::Manifest::PreProcess.new(**kwargs)
        end

        def arena_for(manifest:)
          Rodeo::Arena.for_pre_processing(manifest: manifest, config: config)
        end

        def enqueue(arena:)
          queue.enqueue(derivative_to_process: arena.chain.first.to_sym, arena: arena)
        end
      end
    end
  end
end
