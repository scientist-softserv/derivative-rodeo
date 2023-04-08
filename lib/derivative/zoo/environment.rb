# frozen_string_literal: true

require 'derivative/zoo/chain'
require 'derivative/zoo/storage_adapters'
require 'derivative/zoo/queue_adapters'

module Derivative
  module Zoo
    ##
    # The {Environment} class is responsible for ensuring that for a given {Manifest} and its
    # many possible {Manifest::Derived} objects we process the original file and derivatives in the
    # same environment.
    #
    # @see .for_pre_processing
    # @see .for_mime_type
    #
    # rubocop:disable Metrics/ClassLength
    class Environment
      ##
      # @api public
      #
      # @param manifest [Derivative::Zoo::Manifest::PreProcess]
      # @param config [Derivative::Zoo::Configuration]
      def self.for_pre_processing(manifest:, config: Zoo.config, &block)
        new(manifest: manifest,
            remote_storage: config.remote_storage,
            queue: config.queue,
            local_storage: config.local_storage,
            chain: Chain.for_pre_processing(config: config),
            logger: config.logger,
            config: config,
            &block)
      end

      ##
      # This function builds the environment that transitions from preliminary processing (via
      # {Type::OriginalType} and {Type::MimeType}) to the mime type specific processing.
      #
      # @param environment [Derivative::Zoo::Environment]
      # @param config [Derivative::Zoo::Configuration]
      # @see .for_pre_processing
      def self.for_mime_type_processing(environment:, config: Zoo.config)
        new(local_storage: environment.local_storage,
            remote_storage: environment.remote_storage,
            queue: environment.queue,
            manifest: environment.manifest,
            chain: Chain.from_mime_types_for(manifest: environment.manifest, config: config),
            logger: environment.logger,
            config: config)
      end

      private_class_method :new

      ##
      # @param manifest [Derivative::Zoo::Manifest::Original]
      # @param local_storage [Symbol, Hash<Symbol,Object>, StorageAdapters::Base]
      # @param remote_storage [Symbol, Hash<Symbol,Object>, StorageAdapters::Base]
      # @param queue [Symbol, Hash<Symbol,Object>]
      # @param chain [Chain]
      # @param logger [Logger, Object<#debug, #info, #warn, #error, #fatal>]
      # @param config [Derivative::Zoo::Configuration]
      #
      # @note We have disabled the Metrics/ParameterLists and consider that acceptable because we
      #       have privatized the .new method.
      #
      # @see .for_pre_processing
      # @see .for_mime_type_processing
      #
      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/MethodLength
      def initialize(manifest:, local_storage:, remote_storage:, queue:, chain:, logger:, config:)
        @manifest = manifest
        @local_storage = StorageAdapters.for(manifest: manifest, adapter: local_storage)
        @remote_storage = StorageAdapters.for(manifest: manifest, adapter: remote_storage)
        @queue = QueueAdapters.for(adapter: queue)
        @chain = chain
        @logger = logger
        @config = config

        yield(self) if block_given?

        # rubocop:disable Style/GuardClause
        if dry_run?
          extend Zoo::DryRun.for(method_names: [
                                   :local_assign!,
                                   :local_demand!,
                                   :local_exists?,
                                   :local_path,
                                   :local_read,
                                   :local_run_command!,
                                   :remote_exists?,
                                   :remote_pull!,
                                   :remote_pull
                                 ],
                                 contexts: dry_run_context,
                                 config: config)
        end
        # rubocop:enable Style/GuardClause
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:disable Metrics/MethodLength

      # @return [Derivative::Zoo::Manifest::Original, Derivative::Zoo::Manifest::Derived]
      attr_reader :manifest

      # @return [Derivative::Zoo::StorageAdapters::Base]
      attr_reader :local_storage

      # @return [Derivative::Zoo::StorageAdapters::Base]
      attr_reader :remote_storage

      # @return [Derivative::Zoo::QueueAdapters::Base]
      attr_reader :queue

      # @return [Derivative::Zoo::Chain]
      attr_reader :chain

      # @return [Logger, Object<#debug, #info, #warn, #error, #fatal>]
      attr_reader :logger

      # @return [Derivative::Zoo::Configuration]
      attr_reader :config

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
      delegate :dry_run, :dry_run?, to: :config

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
      # @raise [Derivative::Zoo::Exceptions::UnknownDerivativeRequestForChainError] when the
      #        given :derivative is not part of the {Environment}'s {#chain}.
      def process_next_chain_link_after!(derivative:)
        index = chain.find_index(Derivative::Zoo::Type(derivative))
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
      #       {#remote_storage}'s pull method receives the {#local_storage} as the to: keyword.
      def remote_pull(derivative:)
        remote_storage.pull(derivative: derivative, to: local_storage)
      end

      ##
      # @param derivative [#to_sym]
      #
      # @note Instead of relying on the delegate method and prefix, I want to ensure that the
      #       {#remote_storage}'s pull! method receives the {#local_storage} as the to: keyword.
      def remote_pull!(derivative:)
        remote_storage.pull!(derivative: derivative, to: local_storage)
      end

      ##
      # Delegate the local demand to the given :derivative.  The :derivative knows best.
      #
      # @param derivative [#to_sym]
      def local_demand!(derivative:)
        Zoo.Type(derivative).demand!(manifest: manifest, storage: local_storage)
      end

      ##
      # A bit of indirection to create a common interface for running a shell command; and thus
      # allowing for introducing a dry-run to help in debugging/logging.
      #
      # @param command [String]
      #
      # @note The name of this function follows the idioms of delegator prefix.  It could be that
      #       this function should be on the #local_storage object.
      def local_run_command!(command)
        `#{command}`
      end

      # @api private
      def dry_run_context
        {
          manifest: manifest,
          local_storage: local_storage.to_sym,
          remote_storage: remote_storage.to_sym,
          queue: queue.to_sym,
          chain: chain.to_a
        }
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
