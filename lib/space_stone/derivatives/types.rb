# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/class/attribute'

module SpaceStone
  module Derivatives
    module Types
      ##
      # @api public
      #
      # @param type [Symbol]
      #
      # @return [SpaceStone::Derivatives::BaseType]
      # @raise [NameError] when given type is not registered.
      def self.for(type)
        demodulized_klass = "#{type}_type".classify
        "SpaceStone::Derivatives::Types::#{demodulized_klass}".constantize
      end

      # @abstract
      class BaseType
        class_attribute :prerequisites, default: []

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

        ##
        # @param repository [Repository]
        #
        # @see SpaceStone::Derivatives.pre_process_derivatives_for
        def pre_process!(repository:)
          repository.local_path_for(derivative: to_sym).presence ||
            create_derivative_for(repository: repository)
        end

        private

        def create_derivative_for(repository:)
          raise NotImplementedError
        end
      end
    end
  end
end

require 'space_stone/derivatives/types/hocr_type'
require 'space_stone/derivatives/types/monochrome_type'
