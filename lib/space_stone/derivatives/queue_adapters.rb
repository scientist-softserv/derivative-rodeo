# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module QueueAdapters
      ##
      # @param adapter [Symbol, Hash<Symbol, Object>]
      def self.for(adapter:)
        name = adapter.is_a?(Symbol) ? adapter : adapter.fetch(:name)

        klass = "SpaceStone::Derivatives::QueueAdapters::#{name.to_s.classify}Adapter".constantize
        klass.new
      end

      class InlineAdapter
        def to_hash
          { name: :inline }
        end

        def enqueue(repository:, source:, derivatives:, index:); end
      end
    end
  end
end
