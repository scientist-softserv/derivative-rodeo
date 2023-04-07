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

      delegate :local_read, :local_path, :remote_pull, :process_next_chain_link_after!, :local_exists?, :logger, to: :environment
      delegate :generate_for, to: :derivative

      def call
        returning_value = nil
        returning_value = local_path(derivative: derivative) if local_exists?(derivative: derivative)
        returning_value ||= remote_pull(derivative: derivative).presence
        returning_value ||= generate_for(environment: environment).presence

        raise Exceptions::FailureToLocateDerivativeError.new(derivative: derivative, environment: environment) unless local_exists?(derivative: derivative)

        process_next_chain_link_after!(derivative: derivative)
        returning_value
      end
    end
  end
end
