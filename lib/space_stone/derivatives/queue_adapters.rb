# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module QueueAdapters
      ##
      # @param adapter [Symbol, Hash<Symbol, Object>]
      #
      # @return [SpaceStone::Derivatives::QueueAdapters::Base]
      def self.for(adapter:)
        case adapter
        when Symbol
          klass = "SpaceStone::Derivatives::QueueAdapters::#{adapter.to_s.classify}Adapter".constantize
          klass.new
        when Hash
          self.for(adapter: adapter.fetch(:name))
        when SpaceStone::Derivatives::QueueAdapters::Base
          adapter
        else
          raise Exceptions::UnexpectedQueueAdapterError.new(adapter: adapter)
        end
      end

      module Base
        def to_sym
          self.class.to_s.demodulize.underscore.sub(/_adapter$/, '').to_sym
        end

        def to_hash
          { name: to_sym }
        end

        def enqueue(derivative:, environment:)
          raise NotImplementedError
        end
      end
    end
  end
end

require "space_stone/derivatives/queue_adapters/inline_adapter"
