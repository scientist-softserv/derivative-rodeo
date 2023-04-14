# frozen_string_literal: true
require 'csv'

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
      # @see KNOWN_COLUMN_NAMES
      # @see #call
      class ProcessFileSetsFromCsvInvocation
        include Invocation::Base

        ##
        # @!group Class Attributes
        # @!attribute [r]
        # @return [Hash]
        #
        # @see CSV.parse
        class_attribute(:csv_parse_options, default: { headers: true, encoding: 'utf-8' })

        ##
        # @!attribute [r]
        # @return [Symbol]
        #
        # @todo is this the correct assumption?  Where does this go?  I have a magic symbol
        # propogating throughout the code-base.
        class_attribute(:derivative_to_process, default: :original)
        # @!endgroup Class Attributes

        ##
        # Parse the {#body} (using the {.csv_parse_options})
        #
        # @return [TrueClass] on completion.
        #
        # @todo Consider how we might handle each row.  Should we validate and capture exceptions
        # along the way?
        def call
          CSV.parse(body, **csv_parse_options) do |row|
            manifest = self.class.convert_to_manifest(row: row)
            arena = arena_for(manifest: manifest)
            enqueue(arena: arena)
          end
          true
        end

        # These are the columns that we might see in our CSV.  The required might be a bit of a
        # misnomer as the system does not require a mime_type.
        KNOWN_COLUMN_NAMES = [:parent_identifier, :original_filename, :path_to_original, :mime_type].freeze

        ##
        # @param row [#to_hash]
        # @param known_column_names [Array<Symbol>]
        # @param manifest_builder [Class<Derivative::Rodeo::Manifest>]
        #
        # @return [Derivative::Rodeo::Manifest::PreProcess]
        #
        # @todo What if we don't have the KNOWN_COLUMN_NAMES?
        #
        # @note
        #
        # This is a class method to provide an easier means of testing and sharing the expected
        # behavior.
        #
        # @note
        #
        # This may not be something we can run by posting to a Lambda; however we will need a "split
        # a CSV" into individual queueing.
        def self.convert_to_manifest(row:, known_column_names: KNOWN_COLUMN_NAMES, manifest_builder: Manifest::PreProcess)
          hash = row.to_hash.symbolize_keys
          kwargs = hash.slice(*known_column_names)
          derivatives = hash.except(*known_column_names)
          kwargs[:derivatives] = derivatives
          manifest_builder.new(**kwargs)
        end

        private

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
