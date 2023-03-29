# frozen_string_literal: true

module SpaceStone
  module Derivatives
    class Error < StandardError; end

    module Exceptions
      class TimeToLiveExceededError < Error; end
    end
  end
end
