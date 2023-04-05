# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # The {Environment} class is responsible for ensuring that for a given {Manifest} and its
    # possible many {Manifest::Child} objects we process the original file and derivatives in the
    # same environment.
    #
    # @see .for_original_manifest
    # @see .for_child_manifest
    # @see #to_hash
    class Environment
      class_attribute :local_adapter_name, default: nil, attr_accessor: false
      class_attribute :remote_adapter_name, default: nil, attr_accessor: false
      class_attribute :queue_adapter_name, default: nil, attr_accessor: false

      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param local [Symbol]
      # @param remote [Symbol]
      # @param queue [Symbol]
      # @see .for_child_manifest
      def self.for_original_manifest(manifest:, local: local_adapter_name, queue: queue_adapter_name, remote: remote_adapter_name)
        new(
          manifest: manifest,
          local: local,
          queue: queue,
          remote: remote
        )
      end

      ##
      # Given a child :manifest, create an environment that echoes the given :environment.
      #
      # Why the echo?  Because we want to be writing to similar locations; and the environment helps
      # ensure that.
      #
      # Why not just use the same names as in {.for_original_manifest}?  Because we're letting a
      # named, but not "configured" adapter self-configure.  Once named, we can "reconstitue" that
      # configuration (e.g. the specific temporary directory)
      #
      # @param environment [SpaceStone::Derivatives::Environment]
      # @param manifest [SpaceStone::Derivatives::Manifest::Original::Child]
      # @see .for_original_manifest
      def self.for_child_manifest(environment:, manifest:)
        new(
          manifest: manifest,
          local: environment.local_adapter.to_hash,
          queue: environment.queue_adapter.to_hash,
          remote: environment.remote_adapter.to_hash
        )
      end

      private_class_method :new

      ##
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param local [Symbol, Hash<Symbol,Object>]
      # @param remote [Symbol, Hash<Symbol,Object>]
      # @param queue [Symbol, Hash<Symbol,Object>]
      def initialize(manifest:, local:, remote:, queue:)
        @manifest = manifest
        @local_adapter = StorageAdapters.for(manifest: manifest, adapter: local)
        @remote_adapter = StorageAdapters.for(manifest: manifest, adapter: remote)
        @queue_adapter = QueueAdapters.for(queue)
      end
      attr_reader :manifest, :local_adapter, :remote_adapter, :queue_adapter

      ##
      # A convenience method to pass along "primative" information regarding the environment.
      #
      # @return [Hash<Symbol, Hash>]
      def to_hash
        {
          manifest: manifest.to_hash,
          local_adapter: local_adapter.to_hash,
          remote_adapter: remote_adapter.to_hash,
          queue_adapter: queue.to_hash
        }
      end
    end
  end
end
