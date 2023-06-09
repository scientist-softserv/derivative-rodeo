
# frozen_string_literal: true

module Derivative
  module Rodeo
    module QueueAdapters
      ##
      # The InlineAdapter treats the conceptual "queue" as a pass through.  That is the moment you
      # invoke {#enqueue} we immediate send {Rodeo.process_derivative} a JSON document.
      class InlineAdapter
        include Base

        ##
        # @param derivative_to_process [#to_sym]
        # @param arena [Derivative::Rodeo::Arena]
        def enqueue(derivative_to_process:, arena:)
          Rodeo.process_derivative(json: arena.to_json(derivative_to_process: derivative_to_process), config: arena.config)
        end
      end
    end
  end
end
