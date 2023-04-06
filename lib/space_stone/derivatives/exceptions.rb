# frozen_string_literal: true

module SpaceStone
  module Derivatives
    class Error < StandardError; end

    module Exceptions
      class TimeToLiveExceededError < Error
        def initialize(chain)
          super "Chain #{chain.inspect} has cyclical dependencies."
        end
      end

      # Raised when we do not find an identifier and associated derivative.
      #
      # @see Repository#initialize
      class DerivativeNotFoundError < Error
        def initialize(derivative:, storage:)
          super("Could not find derivative #{derivative.inspect} for storage #{storage.inspect}.")
        end
      end

      class DeprecatedFailureToLocateDerivativeError < Error
        def initialize(derivative:, repository:)
          super("Could not locate #{derivative.inspect} for repository #{repository.inspect}.")
        end
      end

      class FailureToLocateDerivativeError < Error
        def initialize(derivative:, environment:)
          super("Could not locate #{derivative.inspect} for environment #{environment.inspect}.")
        end
      end

      class UnknownDerivativeRequestForChainError < Error
        def initialize(chain:, derivative:)
          super("Expected chain #{chain.inspect} to include derivative #{derivative.inspect}")
        end
      end
    end
  end
end
