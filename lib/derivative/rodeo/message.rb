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
    # - the queue adapter: what is the adapter we're using; this also might include the queue
    #   name that we want to use; likely we're using the same adapter as what we have here but
    #   perhaps a different queue name (determined by the {Type})
    # - the chain: because we need to know what comes next after the current message.
    #
    # @see .to_json
    # @see #to_hash
    # @see https://github.com/scientist-softserv/derivative-rodeo/issues/1 Initial acceptance criteria
    #
    # @note
    #
    #   Other queues also likely have messages to send.  A consistent message helps with tight
    #   interfaces.
    class Message
      ##
      # @api public
      #
      # @param derivative [Derivative::Rodeo::Type]
      # @param arena [Derivative::Rodeo::Arena]
      # @param queue [Derivative::Rodeo::QueueAdapters::Base]
      # @param config [Derivative::Rodeo::Configuration]
      # @param kwargs [Hash]
      # @option kwargs [Object] local_storage
      # @option kwargs [Object] remote_storage
      # @option kwargs [Object] manifest
      #
      # @return [String] A JSON encoded document
      #
      # @see #to_hash
      # @see .from_json
      def self.to_json(arena: nil, derivative:, queue:, config: Rodeo.config, **kwargs)
        kwargs[:local_storage] ||= arena&.local_storage || config.local_storage
        kwargs[:remote_storage] ||= arena&.remote_storage || config.remote_storage
        kwargs[:manifest] ||= arena.manifest
        kwargs[:chain] ||= arena&.chain
        new(**kwargs.merge(queue: queue.to_hash, derivative: derivative.to_sym)).to_hash.to_json
      end

      ##
      # Reify a {Message} based on the provided JSON.
      #
      # @param json [String]
      # @param config [Derivative::Rodeo::Configuration]
      #
      # @return [Derivative::Rodeo::Message]
      #
      # @see .to_json
      def self.from_json(json, config: Rodeo.config)
        manifest = Manifest.from(json.fetch('manifest'))
        local_storage = json.fetch('local_storage', config.local_storage)
        remote_storage = json.fetch('remote_storage', config.remote_storage)
        queue = json.fetch('queue', config.queue)
        derivative = json.fetch('derivative').to_sym # TODO: Insert a default

        # Ensure that the given derivative is part of the chain.
        chain = json.fetch('chain', []) + [derivative]
        new(local_storage: local_storage,
            remote_storage: remote_storage,
            queue: queue,
            manifest: manifest,
            derivative: derivative,
            chain: chain)
      end

      ##
      # @param derivative [Derivative::Rodeo::Type]
      # @param local_storage [Derivative::Rodeo::StorageAdapters::Base]
      # @param remote_storage [Derivative::Rodeo::StorageAdapters::Base]
      # @param manifest [Derivative::Rodeo::Manifest::Base]
      # @param queue [Derivative::Rodeo::QueueAdapters::Base]
      # @param chain [Derivative::Rodeo::Chain]
      # rubocop:disable Metrics/ParameterLists
      def initialize(local_storage:, remote_storage:, manifest:, derivative:, queue:, chain:)
        @manifest = manifest
        @local_storage =  StorageAdapters.for(manifest: manifest, adapter: local_storage)
        @remote_storage = StorageAdapters.for(manifest: manifest, adapter: remote_storage)
        @derivative = derivative
        @queue = QueueAdapters.for(adapter: queue)
        @chain = Chain.new(derivatives: chain)
      end
      # rubocop:enable Metrics/ParameterLists

      ##
      # @return [Derivative::Rodeo::Chain]
      attr_reader :chain

      ##
      # @return [Derivative::Rodeo::Type]
      attr_reader :derivative

      ##
      # @return [Derivative::Rodeo::StorageAdapters::Base]
      attr_reader :local_storage

      ##
      # @return [Derivative::Rodeo::StorageAdapters::Base]
      attr_reader :remote_storage

      ##
      # @return [Derivative::Rodeo::Manifest::Base]
      attr_reader :manifest

      ##
      # @return [Derivative::Rodeo::QueueAdapters::Base]
      attr_reader :queue

      ##
      # @return [Hash<Symbol,Object>]
      def to_hash
        {
          chain: chain.map(&:to_sym),
          derivative: derivative.to_sym,
          local_storage: local_storage.to_hash,
          manifest: manifest.to_hash,
          queue: queue.to_hash,
          remote_storage: remote_storage.to_hash
        }
      end
    end
  end
end
