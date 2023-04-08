# frozen_string_literal: true

module Derivative
  module Zoo
    # Namespace for declaring page_splitters for splitting PDFs.
    module PageSplitters
    end
  end
end

require 'derivative/zoo/page_splitters/base'
require 'derivative/zoo/page_splitters/jpg'
require 'derivative/zoo/page_splitters/png'
require 'derivative/zoo/page_splitters/tiff'
