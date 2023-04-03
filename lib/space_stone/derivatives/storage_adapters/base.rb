# frozen_string_literal: true

module SpaceStone
  module Derivatives
    # The StorageAdapter defines the narrow interface for how {SpaceStone::Derivatives} interacts
    # with the underlying multitude of potential places where we store files.
    module StorageAdapters
      module Base
        ##
        # @api public
        def exists?(derivative:)
          raise NotImplementedError
        end

        # @param derivative [#to_sym]
        #
        # @return [String]
        def read(derivative:)
          raise NotImplementedError
        end

        # @param derivative [#to_sym]
        # @param filename [String]
        #
        # @return [String]
        def path_for(derivative:, filename:)
          raise NotImplementedError
        end

        ##
        # @param derivative [#to_sym]
        #
        # @yield the content to write for the given derivative
        #
        # @example
        #   adapter.write(derivative: :text) { "This is the text" }
        def write(derivative:, &block)
          raise NotImplementedError
        end
      end
    end
  end
end
