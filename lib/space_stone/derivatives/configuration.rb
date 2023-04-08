# frozen_string_literal: true

require 'mime/types'
require 'logger'
module SpaceStone
  module Derivatives
    ##
    # @api public
    class Configuration
      class_attribute :logger_level, default: Logger::FATAL
      class_attribute :dry_run, default: false

      def initialize
        @logger = Logger.new(STDERR, logger_level)
        yield self if block_given?
      end

      attr_accessor :logger

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

      def derivatives_for_pre_process
        @derivatives_for_pre_process || [:original, :mime]
      end

      # @param derivatives [Array<#to_sym>]
      def derivatives_for_pre_process=(derivatives)
        @derivatives_for_pre_process = Array(derivatives).map(&:to_sym)
      end

      def queue
        @queue || :inline
      end
      attr_writer :queue

      def local_storage
        @local_storage || :file_system
      end
      attr_writer :local_storage

      def remote_storage
        @remote_storage || :file_system
      end
      attr_writer :remote_storage
    end
  end
end
