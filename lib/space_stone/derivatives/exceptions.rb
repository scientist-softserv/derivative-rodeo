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
      class NotFoundError < Error
        def initialize(derivative:, repository:)
          super("Could not find derivative #{derivative.inspect} for Repository #{repository.inspect}.")
        end
      end
    end
  end
end
