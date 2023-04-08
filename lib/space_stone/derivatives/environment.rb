# frozen_string_literal: true

require 'space_stone/derivatives/chain'
require 'space_stone/derivatives/storage_adapters'
require 'space_stone/derivatives/queue_adapters'

module SpaceStone
  module Derivatives
    ##
    # The {Environment} class is responsible for ensuring that for a given {Manifest} and its
    # many possible {Manifest::Derived} objects we process the original file and derivatives in the
    # same environment.
    #
    # @see .for_pre_processing
    # @see .for_mime_type
    class Environment
      ##
      # @api public
      #
      # @param manifest [SpaceStone::Derivatives::Manifest::PreProcess]
      # @param config [SpaceStone::Derivatives::Configuration]
      def self.for_pre_processing(manifest:, config: Derivatives.config)
        new(
          manifest: manifest,
          remote_storage: config.remote_storage,
          queue: config.queue,
          local_storage: config.local_storage,
          chain: Chain.for_pre_processing(config: config),
          logger: config.logger
        )
      end

      ##
      # This function builds the environment that transitions from preliminary processing (via
      # {Type::OriginalType} and {Type::MimeType}) to the mime type specific processing.
      #
      # @param environment [SpaceStone::Derivatives::Environment]
      # @param config [SpaceStone::Derivatives::Configuration]
      # @see .for_pre_processing
      def self.for_mime_type_processing(environment:, config: Derivatives.config)
        new(
          local_storage: environment.local_storage,
          remote_storage: environment.remote_storage,
          queue: environment.queue,
          manifest: environment.manifest,
          chain: Chain.from_mime_types_for(manifest: environment.manifest),
          logger: config.logger
        )
      end

      private_class_method :new

      ##
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param local_storage [Symbol, Hash<Symbol,Object>, StorageAdapters::Base]
      # @param remote_storage [Symbol, Hash<Symbol,Object>, StorageAdapters::Base]
      # @param queue [Symbol, Hash<Symbol,Object>]
      # @param chain [Chain]
      # @param logger [Logger, Object<#debug, #info, #warn, #error, #fatal>]
      #
      # @note We have disabled the Metrics/ParameterLists and consider that acceptable because we
      #       have privatized the .new method.
      #
      # @see .for_pre_processing
      # @see .for_mime_type_processing
      #
      # rubocop:disable Metrics/ParameterLists
      def initialize(manifest:, local_storage:, remote_storage:, queue:, chain:, logger:)
        @manifest = manifest
        @local_storage = StorageAdapters.for(manifest: manifest, adapter: local_storage)
        @remote_storage = StorageAdapters.for(manifest: manifest, adapter: remote_storage)
        @queue = QueueAdapters.for(adapter: queue)
        @chain = chain
        @logger = logger
      end
      # rubocop:enable Metrics/ParameterLists

      # @return [SpaceStone::Derivatives::Manifest::Original, SpaceStone::Derivatives::Manifest::Derived]
      attr_reader :manifest

      # @return [SpaceStone::Derivatives::StorageAdapters::Base]
      attr_reader :local_storage

      # @return [SpaceStone::Derivatives::StorageAdapters::Base]
      attr_reader :remote_storage

      # @return [SpaceStone::Derivatives::QueueAdapters::Base]
      attr_reader :queue

      # @return [SpaceStone::Derivatives::Chain]
      attr_reader :chain

      # @return [Logger, Object<#debug, #info, #warn, #error, #fatal>]
      attr_reader :logger

      ##
      # A convenience method to pass along "primative" information regarding the environment.
      #
      # @return [Hash<Symbol, Hash>]
      def to_hash
        {
          chain: chain.to_hash,
          local_storage: local_storage.to_hash,
          manifest: manifest.to_hash,
          queue: queue.to_hash,
          remote_storage: remote_storage.to_hash
        }
      end

      delegate :exists?, :assign!, :path, :read, to: :local_storage, prefix: "local"
      delegate :exists?, to: :remote_storage, prefix: "remote"
      delegate :original_filename, :mime_type, :mime_type=, to: :manifest

      ##
      # Begin the derivating!
      def start_processing!
        # Ensure we have the original file stored locally.
        enqueue(derivative: chain.first)
      end

      ##
      # @param derivative [#to_sym]
      #
      # @return [Symbol] :end_of_chain when we are done processing this chain.
      # @raise [SpaceStone::Derivatives::Exceptions::UnknownDerivativeRequestForChainError] when the
      #        given :derivative is not part of the {Environment}'s {#chain}.
      def process_next_chain_link_after!(derivative:)
        index = chain.find_index(SpaceStone::Derivatives::Type(derivative))
        raise Exceptions::UnknownDerivativeRequestForChainError.new(chain: chain, derivative: derivative) unless index

        next_link = chain.to_a[index + 1]
        return :end_of_chain unless next_link

        enqueue(derivative: next_link)
      end

      def enqueue(derivative:)
        queue.enqueue(derivative: derivative, environment: self)
      end

      private :enqueue

      ##
      # @param derivative [#to_sym]
      #
      # @note Instead of relying on the delegate method and prefix, I want to ensure that the
      #       {#remote}'s pull method receives the {#local} as the to: keyword.
      def remote_pull(derivative:)
        remote_storage.pull(derivative: derivative, to: local_storage)
      end

      ##
      # @param derivative [#to_sym]
      #
      # @note Instead of relying on the delegate method and prefix, I want to ensure that the
      #       {#remote}'s pull! method receives the {#local} as the to: keyword.
      def remote_pull!(derivative:)
        remote_storage.pull!(derivative: derivative, to: local_storage)
      end

      ##
      # Delegate the local demand to the given :derivative.  The :derivative knows best.
      #
      # @param derivative [#to_sym]
      def local_demand!(derivative:)
        Derivatives.Type(derivative).demand!(manifest: manifest, storage: local_storage)
      end
    end
  end
end
