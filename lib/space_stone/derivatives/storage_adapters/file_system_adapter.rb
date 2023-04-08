# frozen_string_literal: true

require 'space_stone/derivatives/storage_adapters/base'
require 'fileutils'

module SpaceStone
  module Derivatives
    module StorageAdapters
      class FileSystemAdapter
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

        # @api public
        def demand!(derivative:)
          return path(derivative: derivative) if exists?(derivative: derivative)

          raise Exceptions::DerivativeNotFoundError.new(derivative: derivative, storage: self)
        end

        ##
        # @api public
        #
        # @param path [String] Assign the contents of the file at the path to the given :derivative
        #        slot.
        # @yield Assign the results of the yielded block to the :derivative slot.
        #
        # @raise [SpaceStone::Derivatives::Exceptions::ConflictingMethodArgumentsError]
        # @raise [Exceptions::DerivativeNotFoundError]
        #
        # @see #demand!
        def assign!(derivative:, path: nil)
          raise Exceptions::ConflictingMethodArgumentsError.new(receiver: self, method: :assign!) if path && block_given?

          if path
            write(derivative: derivative) { File.read(path) }
          else
            write(derivative: derivative) { yield }
          end
          demand!(derivative: derivative)
        end

        # @api public
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
          File.read(path_to(derivative: derivative))
        end

        private

        def write(derivative:)
          File.open(path_to(derivative: derivative), "wb") do |file|
            file.puts yield
          end
        end

        def path_to(derivative:)
          File.join(directory_name, derivative.to_sym.to_s)
        end
      end
    end
  end
end
