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
      # @!group Class Attributes
      # @!attribute [rw]
      # The preliminary processing that needs to happen to kick start the processing.
      #
      # @note Without an initial process to ensure that we have a copy of the :original file in the
      #       {Environment#local}'s storage, we are going to encounter numerous issues.
      # @return [Array<Symbol>]
      class_attribute :preliminary_chain_links, default: [:original]
      # @!endgroup

      ##
      # @param derivatives [Array<#to_sym>]
      def initialize(derivatives:)
        # Don't mind us, these preliminary_chain_links are going to push to the front of the line.
        @chain = (Array(preliminary_chain_links) + Array(derivatives)).each_with_object({}) do |key, hash|
          hash[key.to_sym] = Types.for(key.to_sym)
        end
        add_dependencies_to_chain!
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
      # @yieldparam [SpaceStone::Derivatives::Types::BaseType]
      # @see Sequencer
      def each
        sequence.each do |key|
          yield(@chain.fetch(key))
        end
      end

      private

      # This method ensures that any dependent derivatives that weren't explicitly stated are in
      # fact added to the chain.
      def add_dependencies_to_chain!
        additional_values = {}
        @chain.values.each_with_object(additional_values) do |type, hash|
          Array(type.prerequisites).each do |prereq|
            next if @chain.key?(prereq)
            hash[prereq] = Types.for(prereq)
          end
        end
        return if additional_values.empty?
        @chain.merge!(additional_values)
        add_dependencies_to_chain!
      end

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
