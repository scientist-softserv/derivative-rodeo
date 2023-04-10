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
    # Whereas the {Environment} is the place where we process an original file, the {Configuration}
    # sits above the {Environment} and provides the information for processing all things within the
    # application.
    class Configuration
      class_attribute :dry_run, default: false

      def initialize
        @logger = Logger.new(STDERR, Logger::FATAL)
        # Note the log level synchronization.
        @dry_run_reporter = ->(string) { logger.fatal(string) }
        yield self if block_given?
      end

      attr_accessor :logger

      ##
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

      # !@group Derivative Configurations
      # !@attribute [rw]
      class_attribute :derivatives_by_media_type, default: {
        "image" => [:hocr]
      }
      # !@attribute [rw]
      class_attribute :derivatives_by_mime_type, default: {
        "application/pdf" => [:pdf_split]
      }
      # !@attribute [rw]
      class_attribute(:derivatives_by_sub_type, default: {})
      # !@endgroup Derivative Configurations

      ##
      # @param mime_type [#media_type, #to_s, #sub_type]
      def derivatives_for(mime_type:)
        # Yes a bit of antics to ensure string or symbol keys; maybe not worth it.
        derivatives_by_media_type.fetch(mime_type.media_type, []) +
          derivatives_by_media_type.fetch(mime_type.media_type.to_sym, []) +
          derivatives_by_mime_type.fetch(mime_type.to_s, []) +
          derivatives_by_mime_type.fetch(mime_type.to_s.to_sym, []) +
          derivatives_by_sub_type.fetch(mime_type.sub_type, []) +
          derivatives_by_sub_type.fetch(mime_type.sub_type.to_sym, [])
      end

      # @return [Array<Symbol>] the derivatives that are part of the initial pre-processing.
      #
      # @see Derivative::Rodeo.start_pre_processing!
      def derivatives_for_pre_process
        @derivatives_for_pre_process || [:original, :mime]
      end

      # @param derivatives [Array<#to_sym>]
      #
      # @see Derivative::Rodeo.start_pre_processing!
      def derivatives_for_pre_process=(derivatives)
        @derivatives_for_pre_process = Array(derivatives).map(&:to_sym)
      end

      # @return [Symbol] the name of the queue we're using
      #
      # @see Derivative::Rodeo::QueueAdapters
      def queue
        @queue || :inline
      end
      attr_writer :queue

      # @return [Symbol] the name of the local storage we're using
      #
      # @see Derivative::Rodeo::StorageAdapters
      def local_storage
        @local_storage || :file_system
      end
      attr_writer :local_storage

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
