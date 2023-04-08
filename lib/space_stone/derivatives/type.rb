# frozen_string_literal: true

# This require is technically not needed here, but it helps narrow the concepts elsewhere.
require 'space_stone/derivatives/types'

module SpaceStone
  module Derivatives
    ##
    # @api public
    #
    # A coercing function, similar to Array().
    #
    # @param symbol [#to_sym]
    #
    # @return [SpaceStone::Derivatives::BaseType]
    # @raise [NameError] when given type is not registered.
    #
    # rubocop:disable Naming/MethodName
    def self.Type(symbol)
      demodulized_klass = "#{symbol.to_sym}_type".classify
      "SpaceStone::Derivatives::Type::#{demodulized_klass}".constantize
    end
    # rubocop:enable Naming/MethodName

    ##
    # The module space for declaring named derivative type (e.g. `:image`, `:monochrome`, etc.).  A
    # named derivative type should be able to generate itself based on the given {Environment}.
    #
    # @see BaseType
    # @see BaseType.generate_for
    module Type
      ##
      # @abstract
      # @see Type
      # @see Types
      class BaseType
        class_attribute :prerequisites, default: []
        class_attribute :spawns, default: []

        ##
        # @api public
        #
        # @param environment [SpaceStone::Derivatives::Environment]
        #
        # @see #generate
        def self.generate_for(environment:)
          new(environment: environment).generate
        end

        ##
        # @api public
        #
        # @param manifest [SpaceStone::Derivatives::Manifest]
        # @param storage [SpaceStone::Derivatives::StorageAdapters::Base]
        #
        # rubocop:disable Lint/UnusedMethodArgument
        def self.demand!(manifest:, storage:)
          storage.demand!(derivative: to_sym)
        end
        # rubocop:enable Lint/UnusedMethodArgument

        ##
        # @api public
        #
        # @return [Symbol]
        def self.to_sym
          to_s.demodulize.underscore.sub("_type", "").to_sym
        end

        ##
        # @api public
        # @return [Symbol]
        def to_sym
          self.class.to_sym
        end

        def initialize(environment:)
          @environment = environment
        end
        attr_reader :environment

        def generate
          raise NotImplementedError, "#{self.class}#generate not implemented"
        end
      end
    end
  end
end

require 'space_stone/derivatives/type/fits_type'
require 'space_stone/derivatives/type/hocr_type'
require 'space_stone/derivatives/type/image_type'
require 'space_stone/derivatives/type/mime_type'
require 'space_stone/derivatives/type/monochrome_type'
require 'space_stone/derivatives/type/original_type'
require 'space_stone/derivatives/type/pdf_split_type'
require 'space_stone/derivatives/type/thumbnail_type'
