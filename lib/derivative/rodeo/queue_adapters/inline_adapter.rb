
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
          # json = Message.to_json(queue: self, derivative: derivative, arena: arena, config: arena.config)
          # arena.to_json
          Rodeo.invoke_with(json: arena.to_json(derivative: derivative.to_sym), config: arena.config)
        end
      end
    end
  end
end
