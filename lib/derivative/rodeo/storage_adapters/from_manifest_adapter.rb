# frozen_string_literal: true

require 'derivative/rodeo/storage_adapters/base'
require 'fileutils'

module Derivative
  module Rodeo
    module StorageAdapters
      class FromManifestAdapter
        # Included to provide the method interface and to answer "instance.is_a?(Base)"
        include Base

        ##
        # @param manifest [Derivative::Rodeo::Manifest::Original]
        def initialize(manifest:, **)
          @manifest = manifest
        end
        attr_reader :manifest

        def to_hash
          {
            manifest: manifest.to_hash,
            name: to_sym
          }
        end

        # @api public
        def exists?(derivative:)
          path = path_to(derivative: derivative)
          return false unless path
          return true if File.exist?(path)

          raise "Make sure to handle the URL"
        end

        delegate :path_to, to: :manifest
        alias path path_to

        # @api public
        def demand_path_for!(derivative:)
          return path(derivative: derivative) if exists?(derivative: derivative)

          raise Exceptions::DerivativeNotFoundError.new(derivative: derivative, storage: self)
        end

        # @api public
        def assign!(**)
          raise Exceptions::InvalidFunctionForStorageAdapterError.new(adapter: self, method: :assign!)
        end

        ##
        # @todo
        #
        # What we want to do is write this remote to this location.
        # We want to path the destination and then let the download library write to that destination.
        #
        # This method pull from the remote :to the local
        def pull(derivative:, to:)
          return false unless exists?(derivative: derivative)

          to.fetch!(derivative: derivative, from: self)
        end

        ##
        # @api public
        #
        # For the given :derivative, {#read} it from this storage adapter and then {#assign!} it to the
        # given :to adapter.
        #
        # @param derivative [Symbol]
        # @param to [#assign!, StorageAdapters::Base]
        def pull!(derivative:, to:)
          demand_path_for!(derivative: derivative)

          to.fetch!(derivative: derivative, from: self)
        end

        # This method implements a bit of a double dispatch.
        #
        # First we check if we have it in our storage.  If we do, return the path.  If we don't,
        # have the :from {#push} the :derivative.  The :from knows how it's setup and understands
        # the best way to get it from it's storage to the target storage.  Last we {#demand!} that we
        # have this file locally.
        #
        #
        def fetch!(derivative:, from:)
          return path_to(derivative: derivative) if exists?(derivative: derivative)

          from.push(derivative: derivative, to: self)

          demand_path_for!(derivative: derivative)
        end

        def push(derivative:, to:)
          path = path_to(derivative: derivative)
          if File.exist?(path) # We have a local file, and likely can't leverage downloading logic.
            to.write(derivative: derivative) { read(derivative: derivative) }
          else # We have a remote file, let's rely on downloading
            download(derivative: derivative, path: to.path(derivative: derivative))
          end
        end

        def read(derivative:)
          path = demand_path_for!(derivative: derivative)
          return File.read(path) if File.file?(path)

          # Will we stream these as we write?
          raise "Make sure to handle the URL"
        end

        # rubocop:disable Lint/UnusedMethodArgument
        def write(derivative:)
          raise Exceptions::InvalidFunctionForStorageAdapterError.new(adapter: self, method: :write)
        end
        # rubocop:enable Lint/UnusedMethodArgument
      end
    end
  end
end
