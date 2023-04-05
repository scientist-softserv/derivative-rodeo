# frozen_string_literal: true
require 'forwardable'

module SpaceStone
  module Derivatives
    module Manifest
      class Derived
        Identifier = Struct.new(:original, :derived, :index, keyword_init: true) do
          def id
            "#{original.id}/#{derived}/#{index}"
          end

          def inspect
            "<##{self.class} ID=#{id.inspect}>"
          end

          def directory_slugs
            original.directory_slugs + [derived.to_sym.to_s, index.to_s]
          end

          def to_hash
            {
              derived: derived.to_sym,
              index: index.to_i,
              original: original.to_hash
            }
          end
        end

        def initialize(original:, derived:, index:, derivatives:)
          @identifier = Identifier.new(original: original, derived: derived, index: index)
          @derivatives = Array(derivatives).map(&:to_sym)
        end

        def to_hash
          identifier.to_hash.merge(derivatives: derivatives)
        end

        # @!attribute [rw]
        # @return [Identifier]
        attr_reader :identifier

        # @!attribute [rw]
        # @return [Array<#to_sym>]
        attr_reader :derivatives

        extend Forwardable
        def_delegators :identifier, :original, :derived, :index

        include Comparable
        def <=>(other)
          identifier <=> other.identifier
        end
      end
    end
  end
end
