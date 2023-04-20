# frozen_string_literal: true

require 'derivative/rodeo/storage_adapters/base'
require 'fileutils'

module Derivative
  module Rodeo
    module StorageAdapters
      class FileSystemAdapter
        # Included to provide the method interface and to answer "instance.is_a?(Base)"
        include Base

        ##
        # @param manifest [Derivative::Rodeo::Manifest::Base]
        # @param root [String]
        def initialize(manifest:, root: Dir.mktmpdir)
          super(manifest: manifest)
          @root = root
          @directory_name = File.join(root, *self.manifest.directory_slugs)
          FileUtils.mkdir_p(directory_name)
        end

        ##
        # @return [String]
        attr_reader :root

        ##
        # @return [String]
        attr_reader :directory_name
        private :directory_name

        ##
        # Without the root being passed forward, we loose the local temporary directory.
        #
        # We would not need to pass forward the directory_name as that can be derived.
        def to_hash
          super.merge({ root: root })
        end

        ##
        # @api public
        def assign(derivative:, path:, utility: FileUtils)
          storage_path = path_to_storage(derivative: derivative)
          utility.mkdir_p(File.dirname(storage_path))
          utility.copy_file(path, storage_path)
        end

        ##
        # @api public
        def exists?(derivative:)
          File.file?(path_to_storage(derivative: derivative))
        end

        def fetch!(derivative:, from:)
          demand_path_for!(derivative: derivative) do |storage_path|
            remote_path = from.demand_path_for!(derivative: derivative)

            FileUtils.mkdir_p(File.dirname(storage_path))
            if File.file?(remote_path)
              FileUtils.copy(remote_path, storage_path)
            else
              File.open(storage_path, "wb") do |f|
                f.puts Utilities::Url.read(remote_path)
              end
            end
          end
        end

        ##
        # @todo Do we really want this to be the storage name?  What about using the original
        # filename and adding the suffix of the derivative?
        def path_to_storage(derivative:)
          File.join(directory_name, derivative.to_sym.to_s)
        end
        alias path path_to_storage
        alias path_to path_to_storage
        alias path_for_shell_commands path_to_storage
      end
    end
  end
end
