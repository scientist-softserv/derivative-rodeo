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
        # @param manifest [SpaceStone::Derivatives::Manifest::Original]
        # @param root [String]
        def initialize(manifest:, root: Dir.mktmpdir, directory_name: File.join(root, *manifest.directory_slugs), **)
          @manifest = manifest
          @root = root
          @directory_name = directory_name
          FileUtils.mkdir_p(directory_name)
        end
        attr_reader :manifest, :directory_name, :root

        def to_hash
          {
            directory_name: directory_name,
            manifest: manifest.to_hash,
            name: to_sym,
            root: root
          }
        end

        # @api public
        def exists?(derivative:)
          File.exist?(path_to(derivative: derivative))
        end

        # @api public
        def path(derivative:, **)
          path_to(derivative: derivative)
        end
        alias path_for path

        # @api public
        def demand!(derivative:)
          return path(derivative: derivative) if exists?(derivative: derivative)

          raise Exceptions::DerivativeNotFoundError, derivative: derivative, storage: self
        end

        # @api public
        def assign!(derivative:, path: nil, demand: false, &block)
          if path
            write(derivative: derivative) do
              File.read(path)
            end
          else
            write(derivative: derivative, &block)
          end
          demand!(derivative: derivative) if demand
        end

        # @api public
        def pull!(derivative:, to:)
          demand!(derivative: derivative)

          to.assign!(derivative: derivative) do
            read(derivative: derivative)
          end
        end

        def read(derivative:)
          return false unless exists?(derivative: derivative)

          File.read(path_to(derivative: derivative))
        end

        def write(derivative:)
          File.open(path_to(derivative: derivative), "wb") do |file|
            file.puts yield
          end
        end

        private

        def path_to(derivative:)
          File.join(directory_name, derivative.to_sym.to_s)
        end
      end
    end
  end
end
