# frozen_string_literal: true

module SpaceStone
  module Derivatives
    module Types
      class MonochromeType < BaseType
        def create_derivative_for(repository:)
          # TODO: make this work
          raise repository.inspect
        end
      end
    end
  end
end
