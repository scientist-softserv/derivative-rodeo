# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # The {Environment} class is responsible for ensuring that for a given {Manifest} and its
    # many possible {Manifest::Derived} objects we process the original file and derivatives in the
    # same environment.
    #
    # @see .for_original_manifest
    # @see .for_derived_manifest
    # @see #to_hash
    class Environment
      class_attribute :local_adapter_name, default: nil, instance_accessor: false
      class_attribute :remote_adapter_name, default: nil, instance_accessor: false
      class_attribute :queue_adapter_name, default: nil, instance_accessor: false

      ##
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param local [Symbol]
      # @param remote [Symbol]
      # @param queue [Symbol]
      # @see .for_derived
      def self.for_original(manifest:, local: local_adapter_name, queue: queue_adapter_name, remote: remote_adapter_name)
        new(
          manifest: manifest,
          local: local,
          queue: queue,
          remote: remote
        )
      end

      ##
      # Given a :derived manifest, create an environment that echoes the given :environment.
      #
      # Why the echo?  Because we want to be writing to similar locations; and the environment helps
      # ensure that.
      #
      # Why not just use the same names as in {.for_original_manifest}?  Because we're letting a
      # named, but not "configured" adapter self-configure.  Once named, we can "reconstitue" that
      # configuration (e.g. the specific temporary directory)
      #
      # @param environment [SpaceStone::Derivatives::Environment]
      # @param manifest [SpaceStone::Derivatives::Manifest::Derived]
      # @see .for_original
      def self.for_derived(manifest:, environment:)
        new(**environment.to_hash.merge(manifest: manifest))
      end

      private_class_method :new

      ##
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param local [Symbol, Hash<Symbol,Object>]
      # @param remote [Symbol, Hash<Symbol,Object>]
      # @param queue [Symbol, Hash<Symbol,Object>]
      def initialize(manifest:, local:, remote:, queue:, **kwargs)
        @manifest = manifest
        @local = StorageAdapters.for(manifest: manifest, adapter: local)
        @remote = StorageAdapters.for(manifest: manifest, adapter: remote)
        @queue = QueueAdapters.for(adapter: queue)
        @chain = kwargs.fetch(:chain) { Chain.new(derivatives: manifest.derivatives) }
        @logger = kwargs.fetch(:logger) { Derivatives.logger }
      end

      # @!attribute [r]
      attr_reader :manifest
      # @!attribute [r]
      #   @return [SpaceStone::Derivatives::StorageAdapters::Base]
      attr_reader :local
      # @!attribute [r]
      #   @return [SpaceStone::Derivatives::StorageAdapters::Base]
      attr_reader :remote
      # @!attribute [r]
      #   @return [SpaceStone::Derivatives::QueueAdapters::Base]
      attr_reader :queue
      # @!attribute [r]
      #   @return [SpaceStone::Derivatives::Chain]
      attr_reader :chain

      # @!attribute [r]
      #   @return [#debug, #info, #warn, #error, #fatal]
      attr_reader :logger

      ##
      # A convenience method to pass along "primative" information regarding the environment.
      #
      # @return [Hash<Symbol, Hash>]
      def to_hash
        {
          manifest: manifest.to_hash,
          local: local.to_hash,
          remote: remote.to_hash,
          queue: queue.to_hash
        }
      end

      delegate :exists?, :assign!, :path, :demand!, to: :local, prefix: true
      delegate :exists?, to: :remote, prefix: true

      ##
      # @param derivative [#to_sym]
      def process_start!(derivative: chain.first)
        queue.enqueue(derivative: derivative, environment: self)
      end

      ##
      # @param derivative [#to_sym]
      # @return [Symbol] :end_of_chain when we are done processing this chain.
      # @raise [SpaceStone::Derivatives::Exceptions::UnknownDerivativeRequestForChainError] when the
      #        given :derivative is not part of the {Environment}'s {#chain}.
      def process_next_chain_link_after!(derivative:)
        index = chain.find_index(Types.for(derivative))
        raise Exceptions::UnknownDerivativeRequestForChainError.new(chain: chain, derivative: derivative) unless index

        next_link = chain.to_a[index + 1]
        return :end_of_chain unless next_link

        process_start!(derivative: next_link)
      end

      def remote_pull(derivative:)
        remote.pull(derivative: derivative, to: local)
      end

      def remote_pull!(derivative:)
        remote.pull!(derivative: derivative, to: local)
      end
    end
  end
end
