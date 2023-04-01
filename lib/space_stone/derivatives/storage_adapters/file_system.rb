# frozen_string_literal: true

require 'space_stone/derivatives/storage_adapters/base'

module SpaceStone
  module Derivatives
    module StorageAdapters
      class FileSystem
        # Included to provide the method interface and to answer "instance.is_a?(Base)"
        include Base

        ##
        # @param root [String]
        def initialize(root:)
          @root = root
        end
        attr_reader :root

        def exists?(derivative:)
          File.exist?(path_to(derivative))
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
          File.join(root, derivative.to_sym.to_s)
        end
      end
    end
  end
end
