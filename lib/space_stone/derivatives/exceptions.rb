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
        def initialize(derivative:, repository:)
          super("Could not find derivative #{derivative.inspect} for Repository #{repository.inspect}.")
        end
      end

      class FailureToLocateDerivativeError < Error
        def initialize(derivative:, repository:)
          super("Could not locate #{derivative.inspect} for repository #{repository.inspect}.")
        end
      end

      # Raised when the :processor encounters one or more :errors while processing one or more
      # derivatives.
      #
      # @see Processor
      class ProcessorError < Error
        ##
        # @param processor [Processor]
        # @param errors [Array<Exception>]
        def initialize(processor:, errors:)
          super("Processor #{processor.inspect} encountered #{errors.count} error(s).")
          backtrace = []

          # Given that we have multiple errors, our backtrace is a bit complicated.  We're going to
          # create a single backtrace, but provide some wayfinding.
          errors.each_with_index do |error, i|
            backtrace << "Error ##{i + 1} #{error.class}"
            backtrace << "\t#{error.inspect}"
            backtrace += error.backtrace.map { |line| "#\t\t#{line}" }
          end
          set_backtrace(backtrace)
        end
      end
    end
  end
end
