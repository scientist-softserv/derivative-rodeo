# frozen_string_literal: true

module SpaceStone
  module Derivatives
    # The StorageAdapter defines the narrow interface for how {SpaceStone::Derivatives} interacts
    # with the underlying multitude of potential places where we store files.
    module StorageAdapters
      module Base
        def to_sym
          self.class.to_s.demodulize.underscore.to_sym
        end

        # @api public
        def exists?(derivative:)
          raise NotImplementedError
        end

        # @api public
        def path(derivative:, **)
          raise NotImplementedError
        end

        # @api public
        def demand!(derivative:)
          raise NotImplementedError
        end

        # @api public
        def assign!(derivative:, path: nil, &block)
          raise NotImplementedError
        end

        def read(derivative:)
          raise NotImplementedError
        end

        # @api public
        def pull(derivative:, to:)
          raise NotImplementedError
        end

        # @api public
        def pull!(derivative:, to:)
          raise NotImplementedError
        end
      end
    end
  end
end
