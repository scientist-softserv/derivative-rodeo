# frozen_string_literal: true

module Derivative
  module Rodeo
    # A container for the named exceptions that {Derivative::Rodeo} encounters in it's processing.
    # This is not to say these are the only exceptions.
    #
    # @see Error
    module Exceptions
      # The base error for other named exceptions throughout {Derivative::Rodeo}.
      class Error < StandardError; end

      class ConflictingMethodArgumentsError < Error
        def initialize(receiver:, method:)
          super("Error with arguments for method #{method.inspect} with receiver #{receiver.inspect}.")
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

      class FailureToLocateDerivativeError < Error
        def initialize(derivative:, arena:)
          super("Could not locate #{derivative.inspect} for arena #{arena.inspect}.")
        end
      end

      class ManifestMissingMimeTypeError < Error
        def initialize(manifest:)
          super("Expected manifest #{manifest} to have a defined mime_type.")
        end
      end

      class TimeToLiveExceededError < Error
        def initialize(chain)
          super "Chain #{chain.inspect} has cyclical dependencies."
        end
      end

      class UnexpectedQueueAdapterError < Error
        def initialize(adapter:)
          super("Unexpected adapter #{adapter.inspect}.")
        end
      end

      class UnexpectedStorageAdapterNameError < Error
        def initialize(adapter:, manifest:)
          super("Unexpected adapter #{adapter.inspect} for manifest #{manifest.inspect}.")
        end
      end

      class UnknownDerivativeRequestForChainError < Error
        def initialize(chain:, derivative:)
          super("Expected chain #{chain.inspect} to include derivative #{derivative.inspect}")
        end
      end

      class UnknownMimeTypeError < Error
        def initialize(mime_type:, manifest:)
          super("Unknown mime_type #{mime_type.inspect} for manifest #{manifest.inspect}.")
        end
      end
    end
  end
end
