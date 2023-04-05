# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module QueueAdapters
      ##
      # @param name [Symbol]
      def self.for(name)
        klass = "SpaceStone::Derivatives::QueueAdapters::#{name.to_s.classify}Adapter".constantize
        klass.new
      end

      class InlineAdapter
        def enqueue(repository:, source:, derivatives:, index:); end
      end
    end
  end
end
