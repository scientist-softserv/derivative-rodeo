# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
module SpaceStone
  module Derivatives
    ##
    # The module space for declaring named derivative type (e.g. `:image`, `:monochrome`, etc.).  A
    # named derivative type should be able to generate itself based on the given {Environment}.
    #
    # @see BaseType
    # @see BaseType.generate_for
    module Types
      ##
      # @api public
      #
      # @param type [#to_sym]
      #
      # @return [SpaceStone::Derivatives::BaseType]
      # @raise [NameError] when given type is not registered.
      def self.for(type)
        demodulized_klass = "#{type.to_sym}_type".classify
        "SpaceStone::Derivatives::Types::#{demodulized_klass}".constantize
      end

      ##
      # @abstract
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
          raise NotImplementedError
        end
      end
    end
  end
end

require 'space_stone/derivatives/types/hocr_type'
require 'space_stone/derivatives/types/fits_type'
require 'space_stone/derivatives/types/image_type'
require 'space_stone/derivatives/types/monochrome_type'
require 'space_stone/derivatives/types/original_type'
require 'space_stone/derivatives/types/pdf_split_type'
