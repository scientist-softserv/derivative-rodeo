# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      class HocrType < BaseType
        self.prerequisites = [:monochrome]
      end
    end
  end
end
