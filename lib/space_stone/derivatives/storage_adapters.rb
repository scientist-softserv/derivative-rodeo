# frozen_string_literal: true

module SpaceStone
  module Derivatives
    ##
    # Given that SpaceStone::Derivatives is intended to run in different environments and move data
    # from one storage location to another, we introduce the {StorageAdapters} concept.
    #
    # One adapter is the {StorageAdaptesr::FileSystem}; useful for local testing and perhaps
    # elsewhere.  Other adapters might interact with cloud file storage.
    #
    # @note There is an assumption that all adapters will include the {StorageAdapters::Base} module
    #       to indicate that they conform to the interface.
    #
    # @see StorageAdapters::Base
    # @see .for
    module StorageAdapters
      ##
      # @api public
      #
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param adapter [Symbol, Hash<Symbol,Object>]
      #
      # @raise [NameError]
      # @raise [Exceptions::UnexpectedStorageAdapterNameError]
      # rubocop:disable Metrics/MethodLength
      def self.for(manifest:, adapter:)
        # Why skip the manifest in the adapter?  Because we will assume the provided :manifest is the
        # one we want to configure.
        case adapter
        when StorageAdapters::Base
          # Ensure we coerce the given adapter to a new one.
          self.for(manifest: manifest, adapter: adapter.to_hash)
        when Hash
          name = "#{adapter.fetch(:name).to_s.underscore}_adapter".classify
          kwargs = adapter.except(:name, :manifest, :directory_name)
          klass = "SpaceStone::Derivatives::StorageAdapters::#{name}".constantize
          klass.new(manifest: manifest, **kwargs)
        when Symbol
          name = "#{adapter.to_s.underscore}_adapter".classify
          klass = "SpaceStone::Derivatives::StorageAdapters::#{name}".constantize
          klass.new(manifest: manifest)
        else
          raise Exceptions::UnexpectedStorageAdapterNameError.new(adapter: adapter, manifest: manifest)
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end

require 'space_stone/derivatives/storage_adapters/base'
require 'space_stone/derivatives/storage_adapters/file_system_adapter'
require 'space_stone/derivatives/storage_adapters/from_manifest_adapter'
