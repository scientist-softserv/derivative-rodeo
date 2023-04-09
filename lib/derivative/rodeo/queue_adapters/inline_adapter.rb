
# frozen_string_literal: true

module Derivative
  module Rodeo
    module QueueAdapters
      ##
      # The InlineAdapter treats the conceptual "queue" as a pass through.  That is the moment you
      # invoke {#enqueue} the {#processor} will receive the :call message with the given :derivative
      # and :environment.
      class InlineAdapter
        include Base

        # @param processor [Derivative::Rodeo::Process, #call]
        def initialize(processor: Process)
          @processor = processor
        end

        # @return  [Derivative::Rodeo::Process, #call]
        attr_reader :processor

        # @param derivative [#to_sym]
        # @param environment [Derivative::Rodeo::Environment]
        def enqueue(derivative:, environment:)
          processor.call(derivative: derivative, environment: environment)
        end
      end
    end
  end
end
