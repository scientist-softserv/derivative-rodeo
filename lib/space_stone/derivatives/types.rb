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
      #
      # @note I'm considering the following DSL where the "image_path" is present because of the
      #       declared prerequisite :image.  And the local_assign and local_path are delegated to
      #       the repository.  And then the demand calls are handled by the before and after of the
      #       generate object.
      #
      #    generate do
      #      image = SpaceStone::Derivatives::Utilities::Image.new(image_path)
      #      if image.monochrome?
      #        monochrome_path = image_path
      #      else
      #        monochrome_path = local_path(filename: 'monochrome-interim.tif')
      #        image.convert(monochrome_path, true)
      #      end
      #
      #      local_assign(path: monochrome_path)
      #    end
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

        def generate_for(repository:)
          raise NotImplementedError
        end
      end
    end
  end
end

require 'space_stone/derivatives/types/hocr_type'
require 'space_stone/derivatives/types/image_type'
require 'space_stone/derivatives/types/monochrome_type'
require 'space_stone/derivatives/types/pdf_split_type'
