# frozen_string_literal: true

require 'derivative/rodeo/storage_adapters/base'
require 'fileutils'

module Derivative
  module Rodeo
    module StorageAdapters
      #rubocop:disable Lint/UnusedMethodArgument
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
        def demand!(derivative:)
          return path(derivative: derivative) if exists?(derivative: derivative)

          raise Exceptions::DerivativeNotFoundError, derivative: derivative, storage: self
        end

        # @api public
        def assign!(**)
          raise Exceptions::InvalidFunctionForStorageAdapterError.new(adapter: self, method: :assign!)
        end

        def pull(derivative:, to:)
          return false unless exists?(derivative: derivative)

          to.assign!(derivative: derivative) do
            read(derivative: derivative)
          end
        end

        # @api public
        def pull!(derivative:, to:)
          demand!(derivative: derivative)

          to.assign!(derivative: derivative) do
            read(derivative: derivative)
          end
        end

        def read(derivative:)
          path = demand!(derivative:)
          return File.read(path) if File.exist?(path)

          raise "Make sure to handle the URL"
        end

        def write(derivative:)
          raise InvalidFunctionForStorageAdapterError.new(adapter: self, method: :write)
        end
      end
      #rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
