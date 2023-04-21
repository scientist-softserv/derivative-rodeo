# frozen_string_literal: true
require 'forwardable'

module Derivative
  module Rodeo
    module Manifest
      ##
      # The a {Derived} manifest is for a :first_spawn_step_name file from an {Manifest::Base}.  It
      # has an :index and a list of its own derivatives.
      #
      # The goal is to keep first_spawn_step_name files in a location similar to the original
      # manifest.  Hence we have the first_spawn_step_name and the index values.
      #
      # What's an example of this?  Let's say we have a PDF as the original file.  We want to split
      # the PDF into one image per page.  A single page would have a {Derived} manifest.  The index
      # would likely mean it's page number (starting from 0 as most programming languages do).
      # The derivatives might be [:ocr].
      class Derived
        include Manifest::Base

        Identifier = Struct.new(:original, :first_spawn_step_name, :index, keyword_init: true) do
          def id
            "#{original.id}/#{first_spawn_step_name}/#{index}"
          end

          def inspect
            "<##{self.class} ID=#{id.inspect}>"
          end

          def directory_slugs
            original.directory_slugs + [first_spawn_step_name.to_sym.to_s, index.to_s]
          end

          def to_hash
            {
              first_spawn_step_name: first_spawn_step_name.to_sym,
              index: index.to_i,
              original: original.to_hash
            }
          end
        end

        def initialize(original:, first_spawn_step_name:, index:, derivatives:)
          original = Manifest.from(original)
          @identifier = Identifier.new(original: original, first_spawn_step_name: first_spawn_step_name, index: index)
          @derivatives = Array(derivatives).map(&:to_sym)
        end

        def to_hash
          super.merge(derivatives: derivatives, **identifier.to_hash)
        end

        delegate :id, to: :identifier

        # @!attribute [rw]
        # @return [Identifier]
        attr_reader :identifier

        # @!attribute [rw]
        # @return [Array<#to_sym>]
        attr_reader :derivatives

        extend Forwardable
        def_delegators :identifier, :original, :first_spawn_step_name, :directory_slugs, :index

        include Comparable
        def <=>(other)
          identifier <=> other.identifier
        end
      end
    end
  end
end
