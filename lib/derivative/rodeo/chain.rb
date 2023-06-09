# frozen_string_literal: true

require 'set'
module Derivative
  module Rodeo
    ##
    # This class is responsible for sequencing (and validating) a set of :derivatives.  The {Chain}
    # is necessary to resolve the sequence of derivative generation in the case where we might have
    # second order derivatives.  For example we create an alto file based on a hocr file based on an
    # image.  The alto file would be a second order derivative; it is also a file that could be
    # provided by an end-user.
    #
    # @note
    #   There is an assumption that the start of each chain will be `:base_file_for_chain`.  See
    #   {Step::BaseFileForChainStep} for further discussion.
    #
    # @see #each
    # @see #to_hash
    class Chain
      ##
      # @param config [Derivative::Rodeo::Configuration]
      #
      # @return [Chain]
      #
      # @todo Is this the right place for this?  It's encapsulated so can remain.
      def self.for_pre_processing(config: Rodeo.config)
        new(derivatives: config.derivatives_for_pre_process)
      end

      ##
      # @param derivatives [Array<#to_sym>]
      def initialize(derivatives:)
        # Don't mind us, these preliminary_chain_links are going to push to the front of the line.
        @chain = Array(derivatives).map(&:to_sym).uniq.each_with_object({}) do |(key, _), hash|
          hash[key.to_sym] = Derivative::Rodeo::Step(key.to_sym)
        end
        add_dependencies_to_chain!
      end

      ##
      # @api private
      #
      # @note
      #   Provided to ease the testing of the {Sequencer}.
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
      # @yieldparam [Derivative::Rodeo::Step::BaseStep]
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
        @chain.values.each_with_object(additional_values) do |step, hash|
          Array(step.prerequisites).each do |prereq|
            next if @chain.key?(prereq)
            hash[prereq] = Derivative::Rodeo::Step(prereq)
          end
        end
        return if additional_values.empty?
        @chain.merge!(additional_values)
        add_dependencies_to_chain!
      end

      def sequence
        @sequence ||= Sequencer.call(to_hash)
      end

      ##
      # @api private
      class Sequencer
        ##
        # @api private
        #
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
