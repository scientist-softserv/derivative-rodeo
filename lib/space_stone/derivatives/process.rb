# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given {#derivative} in the given {#environment}
    # and then requesting that the {#environment} process the next chain link after the given
    # {#derivative}.
    #
    # Fundamentally it says
    class Process
      ##
      # @api public
      #
      # @param derivative [SpaceStone::Derivatives::Type::BaseType]
      # @param environment [SpaceStone::Derivatives::Environment]
      #
      # @raise [SpaceStone::Derivatives::Exceptions::FailureToLocateDerivativeError] when we are
      #        unable to find (or generate) the derivative in the given environment.
      #
      # @see #call
      def self.call(derivative:, environment:)
        new(derivative: derivative, environment: environment).call
      end

      def initialize(derivative:, environment:)
        @derivative = derivative
        @environment = environment
      end

      attr_reader :derivative, :environment

      delegate :process_next_chain_link_after!, :local_demand!, :local_exists?, :remote_pull, to: :environment
      delegate :generate_for, to: :derivative

      # @api private
      def call
        local_exists?(derivative: derivative) ||
          remote_pull(derivative: derivative) ||
          generate_for(environment: environment)

        local_demand!(derivative: derivative) && process_next_chain_link_after!(derivative: derivative)
      end
    end
  end
end
