# frozen_string_literal: true

require 'space_stone/derivatives/processes/base'

module SpaceStone
  module Derivatives
    module Processes
      ##
      # Responsible for ensuring that the given :derivative exists as a file in the given
      # :repository.  And if it can't, then raise a {Exceptions::DeprecatedFailureToLocateDerivativeError}.
      #
      # @see #call
      class PreProcess < Processes::Base
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
        #
        # @raise [Exceptions::DeprecatedFailureToLocateDerivativeError]
        def call
          repository.local_for(derivative: derivative).presence ||
            repository.remote_for(derivative: derivative).presence ||
            derivative.generate_for(repository: repository).presence ||
            (raise Exceptions::DeprecatedFailureToLocateDerivativeError.new(derivative: derivative, repository: repository))
        end
      end
    end
  end
end
