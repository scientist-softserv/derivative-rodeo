# frozen_string_literal: true

module SpaceStone
  module Derivatives
    # Namespace for declaring page_splitters for splitting PDFs.
    module PageSplitters
    end
  end
end

require 'space_stone/derivatives/page_splitters/base'
require 'space_stone/derivatives/page_splitters/jpg'
require 'space_stone/derivatives/page_splitters/png'
require 'space_stone/derivatives/page_splitters/tiff'
