# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module StorageAdapters
      ##
      # @param manifest [Manifest]
      # @param adapter [Symbol]
      def self.for(manifest:, adapter:)
        klass = "SpaceStone::Derivatives::StorageAdapters::#{adapter.to_s.classify}".constantize
        klass.new(manifest: manifest)
      end
    end
  end
end

require 'space_stone/derivatives/storage_adapters/base'
require 'space_stone/derivatives/storage_adapters/file_system'
