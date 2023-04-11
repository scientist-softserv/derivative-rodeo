
# frozen_string_literal: true

module Derivative
  module Rodeo
    module QueueAdapters
      ##
      # The InlineAdapter treats the conceptual "queue" as a pass through.  That is the moment you
      # invoke {#enqueue} we immediate send {Rodeo.invoke_with} a {Message}.
      class InlineAdapter
        include Base

        ##
        # @param derivative [#to_sym]
        # @param arena [Derivative::Rodeo::Arena]
        def enqueue(derivative:, arena:)
          message = Message.to_json(queue: self, derivative: derivative, arena: arena, config: arena.config)
          Rodeo.invoke_with(message: message, config: arena.config)
        end
      end
    end
  end
end
