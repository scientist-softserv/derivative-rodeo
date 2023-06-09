# frozen_string_literal: true

# This require is technically not needed here, but it helps narrow the concepts elsewhere.
module Derivative
  module Rodeo
    ##
    # @api public
    #
    # A coercing function, similar to Array().
    #
    # @param symbol [#to_sym]
    #
    # @return [Derivative::Rodeo::Step::BaseStep]
    # @raise [NameError] when given step is not registered.
    #
    # rubocop:disable Naming/MethodName
    def self.Step(symbol)
      demodulized_klass = "#{symbol.to_sym}_step".classify
      "Derivative::Rodeo::Step::#{demodulized_klass}".constantize
    end
    # rubocop:enable Naming/MethodName

    ##
    # The module space for declaring named derivative step (e.g. `:image`, `:monochrome`, etc.).  A
    # named step should be able to generate a derivative file based on the given {Arena}.
    #
    # In some cases, we have pseudo-files (e.g. the {MimeTypeStep}).
    #
    # @see BaseStep
    # @see BaseStep.generate_for
    module Step
      ##
      # @abstract
      # @see Step
      # @see Steps
      class BaseStep
        class_attribute :prerequisites, default: []
        class_attribute :spawns, default: []

        ##
        # @api public
        #
        # @param arena [Derivative::Rodeo::Arena]
        #
        # @see #generate
        def self.generate_for(arena:)
          new(arena: arena).generate
        end

        ##
        # @api public
        #
        # @param manifest [Derivative::Rodeo::Manifest]
        # @param storage [Derivative::Rodeo::StorageAdapters::Base]
        #
        # rubocop:disable Lint/UnusedMethodArgument
        def self.demand_path_for!(storage:)
          storage.demand_path_for!(derivative: to_sym)
        end
        # rubocop:enable Lint/UnusedMethodArgument

        ##
        # @api public
        #
        # @return [Symbol]
        def self.to_sym
          to_s.demodulize.underscore.sub("_step", "").to_sym
        end

        ##
        # @api public
        # @return [Symbol]
        def to_sym
          self.class.to_sym
        end

        def initialize(arena:)
          @arena = arena

          fetch_prerequisite_paths!

          # rubocop:disable Style/GuardClause
          if arena.dry_run?
            extend DryRun.for(method_names: [:local_run_command!, :generate],
                              config: arena.config,
                              contexts: { derivative: self }.merge(arena.dry_run_context))
          end
          # rubocop:enable Style/GuardClause
        end
        attr_reader :arena

        delegate :local_run_command!, to: :arena

        def generate
          raise NotImplementedError, "#{self.class}#generate not implemented"
        end

        private

        ##
        # We know we're going to demand these things; let's make them available.
        def fetch_prerequisite_paths!
          @prerequisite_paths = {}
          prerequisites.each do |prereq|
            @prerequisite_paths["#{prereq}_path".to_sym] ||= arena.local_path_for_shell_commands(derivative: prereq)
          end
        end

        def method_missing(method_name, *args, &block)
          super unless @prerequisite_paths.key?(method_name)
          @prerequisite_paths.fetch(method_name)
        end

        def respond_to_missing?(method_name, include_private = false)
          @prerequisite_paths.key?(method_name) || super
        end
      end
    end
  end
end

# TODO: Have these be auto-discovered
require 'derivative/rodeo/step/fits_step'
require 'derivative/rodeo/step/hocr_step'
require 'derivative/rodeo/step/image_step'
require 'derivative/rodeo/step/mime_type_step'
require 'derivative/rodeo/step/monochrome_step'
require 'derivative/rodeo/step/base_file_for_chain_step'
require 'derivative/rodeo/step/hocr_to_alto_xml_step'
require 'derivative/rodeo/step/pdf_split_step'
require 'derivative/rodeo/step/page_image_step'
require 'derivative/rodeo/step/thumbnail_step'
