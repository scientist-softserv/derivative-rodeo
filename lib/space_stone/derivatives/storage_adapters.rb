# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module StorageAdapters
      ##
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param adapter [Symbol, Hash<Symbol,Object>]
      def self.for(manifest:, adapter:)
        # Why skip the manifest in the adapter?  Because we will assume the provided :manifest is the
        # one we want to configure.
        case adapter
        when StorageAdapters::Base
          # Ensure we coerce the given adapter to a new one.
          self.for(manifest: manifest, adapter: adapter.to_hash)
        when Hash
          name = adapter.fetch(:name)
          kwargs = adapter.except(:name, :manifest, :directory_name)
          klass = "SpaceStone::Derivatives::StorageAdapters::#{name.to_s.classify}".constantize
          klass.new(manifest: manifest, **kwargs)
        when Symbol
          klass = "SpaceStone::Derivatives::StorageAdapters::#{adapter.to_s.classify}".constantize
          klass.new(manifest: manifest)
        else
          raise Exceptions::UnexpectedStorageAdapterNameError.new(adapter: adapter, manifest: manifest)
        end
      end
    end
  end
end

require 'space_stone/derivatives/storage_adapters/base'
require 'space_stone/derivatives/storage_adapters/file_system'
require 'space_stone/derivatives/storage_adapters/from_manifest'
