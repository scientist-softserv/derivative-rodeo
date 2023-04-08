# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module StorageAdapters
      # A module to help document and describe the expected interface for a storage adapter.
      module Base
        def to_sym
          self.class.to_s.demodulize.underscore.sub(/_adapter$/, '').to_sym
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
