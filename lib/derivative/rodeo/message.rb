# frozen_string_literal: true

require 'json'

module Derivative
  module Rodeo
    ##
    # The {Message} sent for and received from enqueuing.
    #
    # It should be bi-directional:
    #
    # I can serialize a message via the {.to_json} method and unserialize via {.from_json}.
    #
    # Fundamentally this needs:
    #
    # - a manifest: The thing from which we can generate a derivative
    # - a derivative: The name of the derivative we want to make
    # - the local storage information: Where are we storing things locally, with some idea of
    #   the specific folder location; which could be handled at the {Configuration} level plus
    #   the {Manifest}'s identifying information.
    # - the remote storage information: A bit more of a black box than the local, as it's a
    #   read-only system.
    # - the queue adapoter: what is the adapter we're using; this also might include the queue
    #   name that we want to use; likely we're using the same adapter as what we have here but
    #   perhaps a different queue name (determined by the {Type})
    #
    # @see .to_json
    # @see #to_hash
    # @see https://github.com/scientist-softserv/derivative-rodeo/issues/1 Initial acceptance criteria
    #
    # @note
    #   Other queues also likely have messages to send.  A consistent message helps with tight
    #   interfaces.
    class Message
      ##
      # @api public
      #
      # @param derivative [Derivatives::Rodeo::Type]
      # @param arena [Derivatives::Rodeo::Arena]
      # @param queue [Derivatives::Rodeo::QueueAdapters::Base]
      #
      # @return [String] A JSON encoded document
      #
      # @see #to_hash
      def self.to_json(arena:, derivative:, queue:)
        new(arena: arena, derivative: derivative, queue: queue).to_hash.to_json
      end

      # @todo Flesh out reification
      # @param json [String]
      def self.from_json(json)
        JSON.parse(json)
      end

      ##
      # @param derivative [Derivatives::Rodeo::Type]
      # @param arena [Derivatives::Rodeo::Arena]
      # @param queue [Derivatives::Rodeo::QueueAdapters::Base]
      def initialize(arena:, derivative:, queue:)
        @arena = arena
        @derivative = derivative
        @queue = queue
      end

      ##
      # @return [Derivatives::Rodeo::Arena]
      attr_reader :arena

      ##
      # @return [Derivatives::Rodeo::Type]
      attr_reader :derivative

      ##
      # @return [Derivatives::Rodeo::QueueAdapters::Base]
      attr_reader :queue

      ##
      # @return [Hash<Symbol,Object>]
      def to_hash
        arena
          .to_hash
          .except(:chain)
          .merge(queue: queue.to_hash, derivative: derivative.to_sym)
      end
    end
  end
end
