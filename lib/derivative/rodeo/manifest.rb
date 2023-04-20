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
      def self.from(value)
        case value
        when Hash
          value = value.symbolize_keys
          name = value.fetch(:name)
          klass = "Derivative::Rodeo::Manifest::#{name.to_s.classify}".constantize
          klass.new(**value.except(:name))
        when Manifest::Base
          value
        else
          raise Exceptions::UnprocessableManifestCoercionError, value
        end
      end

      ##
      # A module for establishing the expected interface
      module Base
        def to_sym
          self.class.to_s.demodulize.underscore.to_sym
        end
        delegate :directory_slugs, to: :identifier

        ##
        # @return [Hash<Symbol,Object>]
        def to_hash
          {
            name: to_sym
          }
        end
      end
    end
  end
end

require 'derivative/rodeo/manifest/original'
require 'derivative/rodeo/manifest/pre_process'
require 'derivative/rodeo/manifest/derived'
