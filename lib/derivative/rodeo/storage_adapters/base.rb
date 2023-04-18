# frozen_string_literal: true

module Derivative
  module Rodeo
    module StorageAdapters
      # A module to help document and describe the expected interface for a storage adapter.
      module Base
        def to_sym
          self.class.to_s.demodulize.underscore.sub(/_adapter$/, '').to_sym
        end

        def to_hash
          { name: to_sym }
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
        def demand_path_for!(derivative:)
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

        def fetch!(derivative:, from:)
          return path_to(derivative: derivative) if exists?(derivative: derivative)

          from.push(derivative: derivative, to: self)

          demand_path_for!(derivative: derivative)
        end
      end
    end
  end
end
