# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module StorageAdapters
      ##
      # @param manifest [SpaceStone::Derivatives::Manifest::Original]
      # @param adapter [Symbol, Hash<Symbol,Object>]
      def self.for(manifest:, adapter:)
        # Why skip the manifest in the adapter?  Because we will assume the provide manifest is the
        # one we want to configure.
        kwargs = adapter.is_a?(Symbol) ? {} : adapter.except(:name, :manifest)
        name = adapter.is_a?(Symbol) ? adapter : adapter.fetch(:name)
        klass = "SpaceStone::Derivatives::StorageAdapters::#{name.to_s.classify}".constantize
        klass.new(manifest: manifest, **kwargs)
      end
    end
  end
end

require 'space_stone/derivatives/storage_adapters/base'
require 'space_stone/derivatives/storage_adapters/file_system'
