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
      # @param manifest [SpaceStone::Derivatives::Manifest]
      def initialize(manifest:)
        @manifest = manifest
      end
      attr_reader :manifest

      # @param derivative [#to_sym]
      #
      # @return [Handle] when the file exists in the local storage
      # @return [NilClass] when the file does not exist in the local storage
      # @see #demand_local_for!
      def local_for(derivative:)
        local_storage.path_to(derivative: derivative)
      end

      # @param derivative [#to_sym]
      # @return [Handle] when the file exists in the local storage
      # @raise [Exceptions::DerivativeNotFoundError] when the given derivative does not exist.
      # @see #local_for
      #
      # rubocop:disable Style/GuardClause
      def demand_local_for!(derivative:)
        if local_storage.exists?(derivative: derivative)
          local_for(derivative: derivative)
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
      def remote_for(derivative:)
        return false unless remote_storage.exists?(derivative: derivative)

        remote_storage.copy(derivative: derivative, to: local_storage)

        demand_local_for!(derivative: derivative)
      end

      ##
      # @api public
      #
      # @param derivative [Symbol]
      # @param path [String]
      #
      # @todo Is contents the correct thing?
      def put(derivative:, path:); end

      ##
      # @api public
      #
      # @param derivative [Symbol]
      #
      # @return [String]
      # @raise [Exceptions::NotFoundError] when we can't find the :manifest's :derivative.
      def local_path_for!(derivative:)
        local_path_for(derivative: derivative).presence ||
          raise(Exceptions::DerivativeNotFoundError.new(derivative: derivative, repository: self))
      end

      # @param derivative [Symbol]
      # @return [String]
      def local_path_for(derivative:)
        # TODO: How to implement?  This might mean I pull down from the remote.  Which depends on the adapter?
      end

      # @param derivative [Symbol]
      # @return [String]
      def local_directory_for(derivative:)
        dir = File.join(tmpdir, derivative.to_s)
        Dir.mkdir(dir)
        dir
      end

      private

      def tmpdir
        @tmpdir ||= Dir.mktmpdir
      end
    end
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
