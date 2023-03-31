# frozen_string_literal: true

require 'space_stone/derivatives/processes/base'

module SpaceStone
  module Derivatives
    module Processes
      ##
      # For pre-processing of a manifest's derivative:
      #
      # 1. Check if the file exists in the expected environment location.  If it does, return a
      #    “handle” to it.
      # 2. Else, if it doesn’t and the manifest says it has a remote URL, attempt to GET it.
      #   - On a 404, log a warning and return `nil`
      #   - On a 2xx, copy it into the expected location, and return the “handle”
      #   - On any other status, log an error and raise an exception.
      # 3. Else, if it can’t be remotely fetched, attempt to generate it.
      #   - On a failure to generate, log an error and raise an exception.
      #   - On a success but there’s no file, log an error and raise an exception.
      #   - On a success with a file, move the file to the expected location and return the “handle”.
      #
      # What is the file “handle”?  Perhaps the path name.
      class PreProcess < Processes::Base
        def call; end
      end
    end
  end
end
