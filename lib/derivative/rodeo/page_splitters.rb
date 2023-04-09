# frozen_string_literal: true

module Derivative
  module Rodeo
    # Namespace for declaring page_splitters for splitting PDFs.
    module PageSplitters
    end
  end
end

require 'derivative/rodeo/page_splitters/base'
require 'derivative/rodeo/page_splitters/jpg'
require 'derivative/rodeo/page_splitters/png'
require 'derivative/rodeo/page_splitters/tiff'
