# frozen_string_literal: true

# This require is technically not needed here, but it helps narrow the concepts elsewhere.
require 'derivative/zoo/types'

module Derivative
  module Zoo
    ##
    # @api public
    #
    # A coercing function, similar to Array().
    #
    # @param symbol [#to_sym]
    #
    # @return [Derivative::Zoo::BaseType]
    # @raise [NameError] when given type is not registered.
    #
    # rubocop:disable Naming/MethodName
    def self.Type(symbol)
      demodulized_klass = "#{symbol.to_sym}_type".classify
      "Derivative::Zoo::Type::#{demodulized_klass}".constantize
    end
    # rubocop:enable Naming/MethodName

    ##
    # The module space for declaring named derivative type (e.g. `:image`, `:monochrome`, etc.).  A
    # named derivative type should be able to generate itself based on the given {Environment}.
    #
    # @see BaseType
    # @see BaseType.generate_for
    module Type
      ##
      # @abstract
      # @see Type
      # @see Types
      class BaseType
        class_attribute :prerequisites, default: []
        class_attribute :spawns, default: []

        ##
        # @api public
        #
        # @param environment [Derivative::Zoo::Environment]
        #
        # @see #generate
        def self.generate_for(environment:)
          new(environment: environment).generate
        end

        ##
        # @api public
        #
        # @param manifest [Derivative::Zoo::Manifest]
        # @param storage [Derivative::Zoo::StorageAdapters::Base]
        #
        # rubocop:disable Lint/UnusedMethodArgument
        def self.demand!(manifest:, storage:)
          storage.demand!(derivative: to_sym)
        end
        # rubocop:enable Lint/UnusedMethodArgument

        ##
        # @api public
        #
        # @return [Symbol]
        def self.to_sym
          to_s.demodulize.underscore.sub("_type", "").to_sym
        end

        ##
        # @api public
        # @return [Symbol]
        def to_sym
          self.class.to_sym
        end

        def initialize(environment:)
          @environment = environment

          # rubocop:disable Style/GuardClause
          if environment.dry_run?
            extend DryRun.for(method_names: [
                                :local_run_command!,
                                :generate
                              ],
                              config: environment.config,
                              contexts: { derivative: self }.merge(environment.dry_run_context))
          end
          # rubocop:enable Style/GuardClause
        end
        attr_reader :environment

        delegate :local_run_command!, to: :environment

        def generate
          raise NotImplementedError, "#{self.class}#generate not implemented"
        end
      end
    end
  end
end

require 'derivative/zoo/type/fits_type'
require 'derivative/zoo/type/hocr_type'
require 'derivative/zoo/type/image_type'
require 'derivative/zoo/type/mime_type'
require 'derivative/zoo/type/monochrome_type'
require 'derivative/zoo/type/original_type'
require 'derivative/zoo/type/pdf_split_type'
require 'derivative/zoo/type/thumbnail_type'
