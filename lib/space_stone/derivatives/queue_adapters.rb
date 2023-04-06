# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module QueueAdapters
      ##
      # @param adapter [Symbol, Hash<Symbol, Object>]
      #
      # @return [SpaceStone::Derivatives::QueueAdapters::Base]
      def self.for(adapter:)
        name = adapter.is_a?(Symbol) ? adapter : adapter.fetch(:name)

        klass = "SpaceStone::Derivatives::QueueAdapters::#{name.to_s.classify}Adapter".constantize
        klass.new
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
