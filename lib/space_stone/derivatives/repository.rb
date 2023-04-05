# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # The purpose of the Repository class is to be a remote storage proxy for content.  Such that
    # the pre_process and ingest could interact with the same files.
    #
    # @note I would envision injecting a storage Strategy adapter.  One for working with S3 and
    #       another for local storage (for offline testing).
    #
    # rubocop:disable Lint/UnusedMethodArgument
    class Repository
      ##
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param local_adapter [Symbol]
      # @param remote_adapter [Symbol]
      #
      # @todo rename the local and remote adapters.  The local adapter is where we're wanting all
      #       files to ultimate end up.  And the remote adapter is where we are going to look if we
      #       don't find the files locally.  These might also make sense as a class_attribute; as
      #       we'll want to configure things in a per environment basis.
      def initialize(manifest:, local_adapter:, remote_adapter:)
        @manifest = manifest
        @local_storage = StorageAdapters.for(adapter: local_adapter, manifest: manifest)
        @remote_storage = StorageAdapters.for(adapter: remote_adapter, manifest: manifest)
      end
      attr_reader :manifest, :local_storage, :remote_storage
      private :local_storage, :remote_storage

      ##
      # The given derivative (via the :from parameter) has identified that it needs SpaceStone to
      # generate the enumerated :derivatives for the file in the given :index.  We do not want to do
      # this inline because we may be hitting boundary conditions.
      #
      # @param source [Symbol] the named source (:original or a derivative type) from which we'll
      #        generate the given :derivatives.
      # @param derivatives [Array<Symbol>] the list of derivatives to generate from the given
      #        derivative.
      # @param index [Integer] the source has a file in the given :index.
      def enqueue(source:, derivatives:, index: 0)
        # We likely want to inject a dependency.
        #
        # When we're running this in AWS, the queue will add a message to SMQ.
        #
        # When we're running this in Bulkrax, the queue might be immediate or we might consider
        # submitting a job.  Regardless the queue is different than the AWS queue.
        #
        # An assumption of the queue is that the local_storage of this repository and the local
        # storage of the queue object are the same (or point to the same "global root").
      end

      ##
      # @param derivative [Symbol]
      # @param filename [String, NilClass]
      def local_path(derivative:, filename: nil, index: 0, mkdir: true)
        local_storage.path_for(derivative: derivative, filename: filename, index: index, mkdir: true)
      end

      ##
      # @param derivative [Symbol]
      # @param path [String]
      # @param demand [Boolean] whether we should automatically call {#demand_local_for!} to verify
      #        the file exists.
      def local_assign(derivative:, path:, index: 0, demand: false)
        local_storage.write(derivative: derivative, index: index) do
          File.read(path)
        end
        demand_local_for!(derivative: derivative, index: index) if demand
      end

      # @param derivative [#to_sym]
      # @return [Handle] when the file exists in the local storage
      # @raise [Exceptions::DerivativeNotFoundError] when the given derivative does not exist.
      # @see #local_for
      #
      # rubocop:disable Style/GuardClause
      def demand_local_for!(derivative:, index: 0)
        if local_storage.exists?(derivative: derivative, index: index)
          local_storage.path_for(derivative: derivative, index: index)
        else
          raise Exceptions::DerivativeNotFoundError, derivative: derivative, repository: self
        end
      end
      # rubocop:enable Style/GuardClause

      # @param derivative [#to_sym]
      # @return [Handle]
      # @raise [Exceptions::DerivativeNotFoundError] when we failed to "localize" the existing
      #        remote derivative.
      #
      # @note A bit of a misnomer on implementation details, but provided for symetry.
      #
      # @see #demand_local_for!
      def remote_for(derivative:, index: 0)
        return false unless remote_storage.exists?(derivative: derivative, index: index)

        remote_storage.copy(derivative: derivative, to: local_storage, index: index)

        demand_local_for!(derivative: derivative, index: index)
      end
    end
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
