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
        # @api public
        def exists?(derivative:)
          path = path_to_storage(derivative: derivative)
          return false unless path
          return true if File.exist?(path)

          Utilities::Url.exists?(path)
        end

        delegate :path_to, to: :manifest
        alias path_to_storage path_to

        ##
        # @raise [Exceptions::InvalidFunctionForStorageAdapterError]
        def assign(**)
          raise Exceptions::InvalidFunctionForStorageAdapterError.new(method: :assign, adapter: self)
        end

        ##
        # @raise [Exceptions::InvalidFunctionForStorageAdapterError]
        def path_for_shell_commands(**)
          raise Exceptions::InvalidFunctionForStorageAdapterError.new(method: :fetch!, adapter: self)
        end

        ##
        # @raise [Exceptions::InvalidFunctionForStorageAdapterError]
        def fetch!(**)
          raise Exceptions::InvalidFunctionForStorageAdapterError.new(method: :fetch!, adapter: self)
        end

        ##
        # @raise [Exceptions::InvalidFunctionForStorageAdapterError]
        def fetch(**)
          raise Exceptions::InvalidFunctionForStorageAdapterError.new(method: :fetch, adapter: self)
        end
      end
    end
  end
end
