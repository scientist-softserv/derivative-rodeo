# frozen_string_literal: true

module Derivative
  module Rodeo
    ##
    # This class is responsible for processing the given {#derivative} in the given {#arena}
    # and then requesting that the {#arena} process the next chain link after the given
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
      # @param derivative [Derivative::Rodeo::Type::BaseType]
      # @param arena [Derivative::Rodeo::Arena]
      #
      # @raise [Derivative::Rodeo::Exceptions::FailureToLocateDerivativeError] when we are
      #        unable to find (or generate) the derivative in the given arena.
      def self.call(derivative:, arena:)
        new(derivative: derivative, arena: arena).call
      end

      def initialize(derivative:, arena:)
        @derivative = derivative
        @arena = arena
      end

      attr_reader :derivative, :arena

      delegate :process_next_chain_link_after!, :local_demand!, :local_exists?, :remote_pull, to: :arena
      delegate :generate_for, to: :derivative

      # @api private
      def call
        local_exists?(derivative: derivative) ||
          remote_pull(derivative: derivative) ||
          generate_for(arena: arena)

        # Will raise an exception if the above failed to put the derivative in the correct local
        # location.
        local_demand!(derivative: derivative)

        process_next_chain_link_after!(derivative: derivative)
      end
    end
  end
end
