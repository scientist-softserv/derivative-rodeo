# frozen_string_literal: true

module Derivative
  module Rodeo
    module QueueAdapters
      ##
      # The NullAdapter ensures that we don't enqueue more things.
      class NullAdapter
        include Base

        ##
        # @param derivative_to_process [#to_sym]
        # @param arena [Derivative::Rodeo::Arena]
        def enqueue(derivative_to_process:, arena:)
          arena.config.logger.debug("Halting processing of derivative #{derivative_to_process.inspect} for arena #{arena.inspect}")
          true
        end
      end
    end
  end
end
