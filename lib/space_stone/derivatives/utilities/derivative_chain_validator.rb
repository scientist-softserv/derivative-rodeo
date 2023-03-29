# frozen_string_literal: true

require 'set'
require 'space_stone/derivatives/exceptions'

module SpaceStone
  module Derivatives
    module Utilities
      # The purpose of this utility is to validate a list of derivatives and their dependencies to
      # ensure that we do not have a circular dependency.
      class DerivativeChainValidator
        ##
        # @param chain [Hash<Symbol, Array<Symbol>>]
        # @param raise_error [true,false]
        #
        # @return [true] when the chain does not have cyclical dependencies
        # @return [false] when the chain has cyclical dependencies
        #
        # @raise [Exceptions::TimeToLiveExceededError] when :raise_error is true and there are
        #        cyclical dependencies.
        def self.call(chain:, raise_error: true)
          return true if new(chain: chain).call

          return false unless raise_error
          raise Exceptions::TimeToLiveExceededError, "Chain #{chain.inspect} has cyclical dependencies"
        end

        def initialize(chain:, time_to_live: 10)
          @chain = chain
          @time_to_live = time_to_live
        end
        attr_reader :chain, :time_to_live

        def call
          return true if chain.empty?

          chain.each do |derivative, dependencies|
            check(derivative, dependencies)
          end

          true
        rescue Exceptions::TimeToLiveExceededError
          false
        end

        private

        def check(_derivative, dependencies, ttl: time_to_live)
          raise Exceptions::TimeToLiveExceededError if ttl.negative?

          return true if dependencies.empty?
          dependencies.each do |dependency|
            child_dependencies = chain.fetch(dependency, [])
            check(dependency, child_dependencies, ttl: ttl - 1)
          end
        end
      end
    end
  end
end
