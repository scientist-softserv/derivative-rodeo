# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module SpaceStone
  module Derivatives
    module Types
      ##
      # @api public
      #
      # @param _type [Symbol]
      # @return [SpaceStone::Derivatives::BaseType]
      def self.for(_type)
        BaseType.new
      end

      # @abstract
      class BaseType
        class_attribute :prerequisites, default: []

        def self.to_sym
          to_s.demodulize.underscore.sub("_type", "").to_sym
        end

        def to_sym
          self.class.to_sym
        end

        ##
        # @param repository [Repository]
        #
        # @see SpaceStone::Derivatives.pre_process_derivatives_for
        def pre_process!(repository:); end
      end
    end
  end
end

require 'space_stone/derivatives/types/hocr_type'
