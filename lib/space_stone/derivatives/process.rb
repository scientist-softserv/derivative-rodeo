# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given {#derivative} in the given {#environment}
    # and then requesting that the {#environment} process the next chain link after the given
    # {#derivative}
    class Process
      ##
      # @param derivative [SpaceStone::Derivatives::Types::BaseType]
      # @param environment [SpaceStone::Derivatives::Environment]
      #
      # @raise [SpaceStone::Derivatives::Exceptions::FailureToLocateDerivativeError] when we are
      #        unable to find (or generate) the derivative in the given environment.
      def self.call(derivative:, environment:)
        new(derivative: derivative, environment: environment)
      end

      def initialize(derivative:, environment:)
        @derivative = derivative
        @environment = environment
      end

      attr_reader :derivative, :environment

      delegate :local_path, :remote_pull, :process_next_chain_link_after!, :logger, to: :environment
      delegate :generate_for, to: :derivative

      def call
        returning_value = local_path(derivative: derivative).presence ||
                          remote_pull(derivative: derivative).presence ||
                          generate_for(environment: environment).presence

        raise Exceptions::FailureToLocateDerivativeError.new(derivative: derivative, environment: environment) unless returning_value

        process_next_chain_link_after!(derivative: derivative)

        returning_value
      end
    end
  end
end
