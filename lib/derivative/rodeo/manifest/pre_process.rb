# frozen_string_literal: true
require 'forwardable'

module Derivative
  module Rodeo
    module Manifest
      class PreProcess
        ##
        # @api public
        #
        # @param parent_identifier [String]
        # @param original_filename [String]
        # @param path_to_original [String] the location where we can find the original file and pull
        #        it into the processing.
        # @param derivatives [Hash<#to_sym, #to_s>] the named existing derivatives and their
        #        locations
        # @param mime_type [String] provided when we already know the object's mime-step; saves a
        #        bit on processing.
        def initialize(parent_identifier:, file_set_filename:, path_to_original:, derivatives: {}, mime_type: nil)
          @identifier = Identifier.new(parent_identifier: parent_identifier, file_set_filename: file_set_filename)
          @path_to_original = path_to_original
          @derivatives = derivatives.each_with_object({}) { |(key, value), hash| hash[key.to_sym] = value.to_s }
          @mime_type = mime_type
        end

        Identifier = Struct.new(:parent_identifier, :file_set_filename, keyword_init: true) do
          def id
            "#{parent_identifier}/#{file_set_filename}"
          end

          def inspect
            "<##{self.class} ID=#{id.inspect}>"
          end

          def directory_slugs
            [parent_identifier.to_s, File.basename(file_set_filename)]
          end

          def to_hash
            {
              parent_identifier: parent_identifier,
              file_set_filename: file_set_filename
            }
          end
        end

        include Manifest::Base

        def to_hash
          super.merge(derivatives: derivatives,
                      mime_type: mime_type,
                      file_set_filename: file_set_filename,
                      parent_identifier: parent_identifier,
                      path_to_original: path_to_original)
        end

        def path_to(derivative:)
          return path_to_original if derivative.to_sym == :original

          derivatives[derivative.to_sym]
        end

        ##
        # @return [String]
        attr_accessor :mime_type

        attr_reader :identifier
        delegate :id, :parent_identifier, :file_set_filename, :directory_slugs, to: :identifier

        ##
        # @return [Hash<Symbol, String>]
        attr_reader :derivatives

        ##
        # @return [String]
        attr_reader :path_to_original
      end
    end
  end
end
