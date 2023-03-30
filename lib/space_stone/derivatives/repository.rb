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
    # @see #put
    # @see #get
    # rubocop:disable Lint/UnusedMethodArgument
    class Repository
      ##
      # @param identifier [SpaceStone::Derivatives::Manifest::Identifier]
      def initialize(identifier:)
        @identifier = identifier
      end
      attr_reader :identifier

      def inspect
        %(<##{self.class} @identifier=#{identifier.inspect}>)
      end

      ##
      # @api public
      #
      # This function writes the binary :contents into a place where the {#get} method can find it
      # for the given :identifier and :derivative.
      #
      # @param identifier [Manifest::Identifier]
      # @param derivative [Symbol]
      # @param path [String]
      #
      # @see #get
      #
      # @todo Is contents the correct thing?
      def put(derivative:, path:); end

      ##
      # @api public
      #
      # @param derivative [Symbol]
      #
      # @see #put
      #
      # @return [String]
      # @raise [Exceptions::NotFoundError] when we can't find the :identifier's :derivative.
      def local_path_for!(derivative:)
        local_path_for(derivative: derivative).presence ||
          raise(Exceptions::NotFoundError.new(derivative: derivative, repository: self))
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
