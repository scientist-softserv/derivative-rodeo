# frozen_string_literal: true

require 'mime/types'
require 'logger'
module Derivative
  module Rodeo
    ##
    # @api public
    #
    # This class is responsible for the consistent configuration of the "application" that leverages
    # the {Derivative::Rodeo}.
    #
    # Whereas the {Arena} is the place where we process an original file, the {Configuration}
    # sits above the {Arena} and provides the information for processing all things within the
    # application.
    class Configuration
      def initialize
        @logger = Logger.new(STDERR, Logger::FATAL)
        # Note the log level synchronization.
        @dry_run_reporter = ->(string) { logger.info("\n#{string}\n") }
        yield self if block_given?
      end

      attr_accessor :logger

      ##
      # @!group Dry Run Configurations
      #
      # The desired mechanism for reporting on the {DryRun} activity.
      #
      # @example
      #   ##
      #   # Send the dry notices to STDERR
      #   Derivative::Rodeo.config do |cfg|
      #     cfg.dry_run_reporter = ->(text) { $stderr.puts text }
      #   end
      # @return [#call]
      attr_accessor :dry_run_reporter

      # @!attribute [rw]
      # @return [Boolean]
      class_attribute :dry_run, default: false
      # @!endgroup Dry Run Configurations

      ##
      # @return [Array<Symbol>] the derivatives that are part of the initial pre-processing.
      def derivatives_for_pre_process
        @derivatives_for_pre_process || [:base_file_for_chain, :mime_type]
      end

      ##
      # @param derivatives [Array<#to_sym>]
      #
      # @see Derivative::Rodeo.start_pre_processing
      def derivatives_for_pre_process=(derivatives)
        @derivatives_for_pre_process = Array(derivatives).map(&:to_sym)
      end

      ##
      # @return [Symbol] the name of the queue we're using
      #
      # @see Derivative::Rodeo::QueueAdapters
      def queue
        @queue || :inline
      end
      attr_writer :queue

      ##
      # @return [Symbol] the name of the local storage we're using
      #
      # @see Derivative::Rodeo::StorageAdapters
      def local_storage
        @local_storage || :file_system
      end
      attr_writer :local_storage

      ##
      # @return [Symbol] the name of the local storage we're using
      #
      # @see Derivative::Rodeo::StorageAdapters
      def remote_storage
        @remote_storage || :file_system
      end
      attr_writer :remote_storage
    end
  end
end
