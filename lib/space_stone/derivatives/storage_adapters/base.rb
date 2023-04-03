# frozen_string_literal: true

module SpaceStone
  module Derivatives
    # The StorageAdapter defines the narrow interface for how {SpaceStone::Derivatives} interacts
    # with the underlying multitude of potential places where we store files.
    module StorageAdapters
      module Base
        ##
        # @api public
        # @param derivative [#to_sym]
        # @param index [Integer]
        def exists?(derivative:, index: 0)
          raise NotImplementedError
        end

        # @param derivative [#to_sym]
        # @param index [Integer]
        #
        # @return [String]
        def read(derivative:, index: 0)
          raise NotImplementedError
        end

        # @param derivative [#to_sym]
        # @param filename [String]
        # @param index [Integer]
        #
        # @return [String]
        def path_for(derivative:, filename:, index: 0)
          raise NotImplementedError
        end

        ##
        # @param derivative [#to_sym]
        # @param index [Integer]
        #
        # @yield the content to write for the given derivative
        #
        # @example
        #   adapter.write(derivative: :text) { "This is the text" }
        def write(derivative:, index: 0 & block)
          raise NotImplementedError
        end
      end
    end
  end
end
