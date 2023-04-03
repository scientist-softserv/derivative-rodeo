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

        def exists?(derivative:)
          File.exist?(path_to(derivative))
        end

        def path_for(derivative:, **)
          path_to(derivative)
        end

        def read(derivative:)
          return false unless exists?(derivative: derivative)

          File.read(path_to(derivative))
        end

        def write(derivative:)
          File.open(path_to(derivative), "wb") do |file|
            file.puts yield
          end
        end

        private

        def path_to(derivative)
          File.join(directory_name, derivative.to_sym.to_s)
        end
      end
    end
  end
end
