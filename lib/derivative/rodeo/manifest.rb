# frozen_string_literal: true
require 'forwardable'

module Derivative
  module Rodeo
    ##
    # The {Manifest} contains the informational metadata regarding the original file we're
    # processing.
    #
    # @see Derivative::Rodeo::Manifest::PreProcess
    module Manifest
    end
  end
end

require 'derivative/rodeo/manifest/original'
require 'derivative/rodeo/manifest/pre_process'
require 'derivative/rodeo/manifest/derived'