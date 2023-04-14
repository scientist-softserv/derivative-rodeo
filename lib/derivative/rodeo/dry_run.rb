# frozen_string_literal: true

module Derivative
  module Rodeo
    ##
    # This module exposes the convenience method {.for} to create a module that will wrap methods
    # such that you can see what's being called without doing all the processing.
    #
    # Why?  Because in our testing and development, it could sometimes be opaque where things were
    # failing.  In particular with the addition of the {QueueAdapters::InlineAdapter} that allows
    # for inline processing; creating a chain of processes.
    #
    # @see .for
    module DryRun
      ##
      # @param method_names [Array<Symbols>]
      # @param contexts [Hash] for rendering additional context on the command line.
      # @param config [Derivative::Rodeo::Configuration]
      #
      # @return [Module]
      #
      # @example
      #   Person = Struct.new(:first_name, :last_name)
      #   person = Person.new("No", "Man")
      #   person.extend(Derivative::Rodeo::DryRun.for(method_names: :first_name))
      #
      # @note
      #   Given that we're returning a Module the receiver must either include or extend the
      #   caller with the returned module.
      def self.for(method_names:, contexts: [], config: Rodeo.config)
        context_message = ""
        items = contexts.map { |key, value| "#{key}: #{value.inspect}" }
        context_message = " for #{items.join(', ')}" if items.present?

        Module.new do
          Array(method_names).each do |method_name|
            define_method(method_name) do |*args|
              config.dry_run_reporter.call("Calling #{self.class}##{method_name}(#{args.inspect})#{context_message}.")
              yield if block_given?
              false
            end
          end
        end
      end
    end
  end
end
