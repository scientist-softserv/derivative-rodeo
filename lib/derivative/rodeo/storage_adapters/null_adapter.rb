# frozen_string_literal: true

require 'derivative/rodeo/storage_adapters/base'
require 'fileutils'

module Derivative
  module Rodeo
    module StorageAdapters
      ##
      # We want a way to say we have no remote storage.
      class NullAdapter
        # Included to provide the method interface and to answer "instance.is_a?(Base)"
        include Base

        def exists?(**)
          false
        end
      end
    end
  end
end
