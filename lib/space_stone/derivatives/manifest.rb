# frozen_string_literal: true
require 'forwardable'

module SpaceStone
  module Derivatives
    ##
    # There are two uses for this data structure:
    #
    # - Pre-processing
    # - Ingesting
    #
    # During the pre-process we want to specify the derivatives that we will generate for the given
    # {Identifier}.  The {Identifier} should be a unique combination of the `parent_identifier` and
    # the `original_filename`.
    #
    # During the ingest the declared derivatives are all of the derivative files that we intend to
    # attach to the given {Identifier}.
    #
    # In other words, throughout the processing of an {Identifier}.
    #
    # @note In Hyrax the `original_filename` would be the name of the original file for a FileSet
    #       associated with the Work identified by the `parent_identifier`.
    class Manifest
      # The Identifier is a combination of the `parent_identifier` and the `original_filename`.
      #
      # @note In leveraging a Struct we get easy comparision for uniquness.
      Identifier = Struct.new(:parent_identifier, :original_filename, keyword_init: true) do
        def id
          "#{parent_identifier}/#{original_filename}"
        end

        def inspect
          "<##{self.class} ID=#{id.inspect}>"
        end

        def directory_slugs
          [parent_identifier.to_s, File.basename(original_filename)]
        end

        def to_hash
          {
            parent_identifier: parent_identifier,
            original_filename: original_filename
          }
        end
      end

      ##
      # @api public
      #
      # @param parent_identifier [String]
      # @param original_filename [String]
      # @param derivatives [Array<#to_sym>]
      def initialize(parent_identifier:, original_filename:, derivatives:)
        @identifier = Identifier.new(parent_identifier: parent_identifier, original_filename: original_filename)
        @derivatives = Array(derivatives).map(&:to_sym)
      end

      def to_hash
        identifier.to_hash.merge(derivatives: derivatives)
      end

      # @!attribute [rw]
      # @return [Identifier]
      attr_reader :identifier

      # @!attribute [rw]
      # @return [Array<#to_sym>]
      attr_reader :derivatives

      # Given the that the parent_identifier and original_filename should be unique, we're including
      # the {Comparable} module to help with the uniqueness via the `<=>` operator (e.g. the
      # Spaceship operator).
      extend Forwardable
      include Comparable
      def_delegators :identifier, :parent_identifier, :original_filename, :directory_slugs

      def <=>(other)
        identifier <=> other.identifier
      end
    end
  end
end
