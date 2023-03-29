# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module SpaceStone
  module Derivatives
    module Types
      # @abstract
      class BaseType
        class_attribute :prerequisites, default: []

        def self.to_sym
          to_s.demodulize.underscore.sub("_type", "").to_sym
        end

        def to_sym
          self.class.to_sym
        end
      end
    end
  end
end

require 'space_stone/derivatives/types/hocr_type'
