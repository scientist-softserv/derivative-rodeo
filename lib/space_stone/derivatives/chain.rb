# frozen_string_literal: true

require 'set'
require 'space_stone/derivatives/types'

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for sequencing (and validating) a set of :derivatives.
    #
    # @see #each
    # @see #to_hash
    class Chain
      # @param derivatives [Array<#to_sym>]
      def initialize(derivatives:)
        @chain = Array(derivatives).each_with_object({}) { |key, hash| hash[key.to_sym] = Types.for(key.to_sym) }
      end

      ##
      # @api private
      #
      # @note Provided to ease the testing of the {Sequencer}.
      def to_hash
        @to_hash ||= @chain.each_with_object({}) do |(key, derivative), hash|
          hash[key.to_sym] = derivative.prerequisites
        end
      end

      include Enumerable
      ##
      # @api public
      #
      # Yield the derivatives for processing in the correct sequence, accounting for the
      # prerequisites of the derivatives.
      #
      # @yield [SpaceStone::Derivatives::Types::BaseType]
      # @see Sequencer
      def each
        sequence.each do |key|
          yield(@chain.fetch(key))
        end
      end

      private

      def sequence
        @sequence ||= Sequencer.call(to_hash)
      end

      class Sequencer
        ##
        # @param chain [Hash<Symbol, Array<Symbol>>]
        # @param raise_error [true,false] provided as a testing facilitator.
        #
        # @return [#each]
        #
        # @raise [Exceptions::TimeToLiveExceededError] when :raise_error is
        #        true and there are cyclical dependencies.
        def self.call(chain, raise_error: true)
          new(chain).call
        rescue Exceptions::TimeToLiveExceededError => e
          return [] unless raise_error
          raise e
        end

        def initialize(chain, time_to_live: 10)
          @chain = chain
          @time_to_live = time_to_live
        end
        attr_reader :chain, :time_to_live

        def call
          accumulator = Set.new

          chain.each do |derivative, dependencies|
            accumulate(derivative, dependencies, accumulator)
          end

          accumulator.to_a
        end

        private

        def accumulate(derivative, dependencies, accumulator, ttl: time_to_live)
          raise Exceptions::TimeToLiveExceededError, chain if ttl.negative?

          dependencies.each do |dependency|
            child_dependencies = chain.fetch(dependency, [])
            accumulate(dependency, child_dependencies, accumulator, ttl: ttl - 1)
          end
          accumulator << derivative
        end
      end
    end
  end
end
