# frozen_string_literal: true

require 'json'
require 'open3'
require 'tmpdir'
require 'forwardable'

module Derivative
  module Rodeo
    module TextExtractors
      class Ocr
        def initialize(path)
          @path = path
          @words = nil
          @plain = nil
        end

        attr_reader :path

        # This is the core function of the class.  All others depend on it.
        def load_words
          preprocess_image
          html_path = run_ocr
          hocr = Hocr.new(html_path)
          @words = hocr.words
          @plain = hocr.text
        end

        def run_ocr
          Tesseract.call(path: path)
        end

        def words
          load_words if @words.nil?
          @words
        end

        def word_json
          @word_json ||= WordCoordinates.to_json(
            words: words,
            width: width,
            height: height
          )
        end

        def plain
          load_words if @plain.nil?
          @plain
        end

        def technical_metadata
          @technical_metadata ||= Utilities::Image.new(@path).technical_metadata
        end
        alias identify technical_metadata

        extend Forwardable

        def_delegators :technical_metadata, :width, :height

        def alto
          @alto ||= Alto.to_alto(words: words, width: width, height: height)
        end

        private

        # transform the image into a one-bit TIFF for OCR
        def preprocess_image
          tool = Utilities::Image.new(@path)
          return if tool.metadata.color == 'monochrome'
          intermediate_path = File.join(Dir.mktmpdir, 'monochrome-interim.tif')
          tool.convert(intermediate_path, true)
          @path = intermediate_path
        end
      end
    end
  end
end
