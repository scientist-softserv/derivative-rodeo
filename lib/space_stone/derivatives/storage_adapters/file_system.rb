# frozen_string_literal: true

require 'space_stone/derivatives/storage_adapters/base'
require 'fileutils'

module SpaceStone
  module Derivatives
    module StorageAdapters
      class FileSystem
        # Included to provide the method interface and to answer "instance.is_a?(Base)"
        include Base

        ##
        # @param manifest [Manifest]
        # @param root [String]
        def initialize(manifest:, root: Dir.mktmpdir)
          @manifest = manifest
          @root = root
          @directory_name = File.join(root, *manifest.directory_slugs)
          FileUtils.mkdir_p(directory_name)
        end
        attr_reader :manifest, :root, :directory_name

        def exists?(derivative:, index: 0)
          File.exist?(path_to(derivative: derivative, index: index))
        end

        def path_for(derivative:, index: 0, mkdir: false, **)
          path_to(derivative: derivative, index: index, mkdir: mkdir)
        end

        def read(derivative:, index: 0)
          return false unless exists?(derivative: derivative, index: index)

          File.read(path_to(derivative: derivative, index: index))
        end

        def write(derivative:, index: 0)
          File.open(path_to(derivative: derivative, index: index, mkdir: true), "wb") do |file|
            file.puts yield
          end
        end

        private

        def path_to(derivative:, index:, mkdir: false)
          FileUtils.mkdir_p(File.join(directory_name, derivative.to_sym.to_s)) if mkdir

          File.join(directory_name, derivative.to_sym.to_s, index.to_s)
        end
      end
    end
  end
end
