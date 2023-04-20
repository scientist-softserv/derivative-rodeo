# frozen_string_literal: true

module Derivative
  module Rodeo
    ##
    # Given that Derivative::Rodeo is intended to run in different arenas and move data
    # from one storage location to another, we introduce the {StorageAdapters} concept.
    #
    # One adapter is the {StorageAdapters::FileSystemAdapter}; useful for local testing and perhaps
    # elsewhere.  Other adapters might interact with cloud file storage.
    #
    # @note
    #   There is an assumption that all adapters will include the {StorageAdapters::Base} module to
    #   indicate that they conform to the interface.
    #
    # @see StorageAdapters::Base
    # @see StorageAdapters::FileSystem
    # @see .for
    module StorageAdapters
      ##
      # @api public
      #
      # @param manifest [Derivative::Rodeo::Manifest, Hash]
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
          adapter = adapter.symbolize_keys
          name = "#{adapter.fetch(:name).to_s.underscore}_adapter".classify
          kwargs = adapter.except(:name, :manifest, :directory_name)
          klass = "Derivative::Rodeo::StorageAdapters::#{name}".constantize
          klass.new(manifest: manifest, **kwargs)
        when Symbol
          name = "#{adapter.to_s.underscore}_adapter".classify
          klass = "Derivative::Rodeo::StorageAdapters::#{name}".constantize
          klass.new(manifest: manifest)
        else
          raise Exceptions::UnexpectedStorageAdapterNameError.new(adapter: adapter, manifest: manifest)
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end

require 'derivative/rodeo/storage_adapters/base'
require 'derivative/rodeo/storage_adapters/aws_s3_adapter'
require 'derivative/rodeo/storage_adapters/file_system_adapter'
require 'derivative/rodeo/storage_adapters/from_manifest_adapter'
require 'derivative/rodeo/storage_adapters/null_adapter'
