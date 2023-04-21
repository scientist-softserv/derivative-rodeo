# frozen_string_literal: true

module Derivative
  module Rodeo
    ##
    # The queue used for processing the derivatives; the queue is necessary because we need to run
    # locally and in the cloud.  The adapter is here to define the interface in the
    # {QueueAdapters::Base}.
    #
    # @see InlineAdapter
    # @see AwsSqsAdapter
    module QueueAdapters
      ##
      # @param adapter [Symbol, Hash<Symbol, Object>]
      #
      # @return [Derivative::Rodeo::QueueAdapters::Base]
      def self.for(adapter:)
        case adapter
        when Symbol, String
          klass = "Derivative::Rodeo::QueueAdapters::#{adapter.to_s.classify}Adapter".constantize
          klass.new
        when Hash
          adapter = adapter.symbolize_keys
          self.for(adapter: adapter.fetch(:name))
        when Derivative::Rodeo::QueueAdapters::Base
          adapter
        else
          raise Exceptions::UnexpectedQueueAdapterError.new(adapter: adapter)
        end
      end

      # Helps define the public interface for other {QueueAdapters}.
      module Base
        def to_sym
          self.class.to_s.demodulize.underscore.sub(/_adapter$/, '').to_sym
        end

        def to_hash
          { name: to_sym }
        end

        def enqueue(derivative_to_process:, arena:)
          raise NotImplementedError, "#{self.class}#enqueue"
        end
      end
    end
  end
end

require "derivative/rodeo/queue_adapters/aws_sqs_adapter"
require "derivative/rodeo/queue_adapters/inline_adapter"
require "derivative/rodeo/queue_adapters/null_adapter"
