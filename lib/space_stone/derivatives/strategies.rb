# frozen_string_literal: true

module SpaceStone
  module Derivatives
    # Namespace for declaring strategies for splitting PDFs.
    module Strategies
    end
  end
end

require 'space_stone/derivatives/strategies/base'
require 'space_stone/derivatives/strategies/jpg'
require 'space_stone/derivatives/strategies/png'
require 'space_stone/derivatives/strategies/tiff'
