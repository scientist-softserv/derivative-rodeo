# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # This class is responsible for processing the given {#derivative} in the given {#environment}
    # and then requesting that the {#environment} process the next chain link after the given
    # {#derivative}.
    #
    # @see .call
    class Process
      ##
      # @api public
      #
      # This is some of the core conceptual logic of the application:
      #
      # - I have the file locally…
      # - failing that, I get the remote…
      # - failing that I generate it…
      # - failing that I raise [#Exceptions::FailureToLocateDerivativeError]
      # - and if no exception is raised, I proceed with processing the next derivative.
      #
      # @param derivative [SpaceStone::Derivatives::Type::BaseType]
      # @param environment [SpaceStone::Derivatives::Environment]
      #
      # @raise [SpaceStone::Derivatives::Exceptions::FailureToLocateDerivativeError] when we are
      #        unable to find (or generate) the derivative in the given environment.
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

        # Will raise exception if things fail
        local_demand!(derivative: derivative)

        process_next_chain_link_after!(derivative: derivative)
      end
    end
  end
end
