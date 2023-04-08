
# frozen_string_literal: true

module Derivative
  module Zoo
    module QueueAdapters
      ##
      # The InlineAdapter treats the conceptual "queue" as a pass through.  That is the moment you
      # invoke {#enqueue} the {#processor} will receive the :call message with the given :derivative
      # and :environment.
      class InlineAdapter
        include Base

        # @param processor [Derivative::Zoo::Process, #call]
        def initialize(processor: Process)
          @processor = processor
        end

        # @return  [Derivative::Zoo::Process, #call]
        attr_reader :processor

        # @param derivative [#to_sym]
        # @param environment [Derivative::Zoo::Environment]
        def enqueue(derivative:, environment:)
          processor.call(derivative: derivative, environment: environment)
        end
      end
    end
  end
end
