# frozen_string_literal: true

require 'mime/types'
module SpaceStone
  module Derivatives
    ##
    # @api public
    class Configuration
      # !@group Derivative Configurations
      # !@attribute [rw]
      class_attribute :derivatives_by_media_type, default: {
        "image" => [:hocr, :thumbnail]
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
    end
  end
end
