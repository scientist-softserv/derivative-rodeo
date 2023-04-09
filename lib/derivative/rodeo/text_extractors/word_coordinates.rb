# frozen_string_literal: true
require 'json'

module Derivative
  module Rodeo
    module TextExtractors
      class WordCoordinates
        ##
        # @api public
        #
        # @param words [Array<Hash>] an array of hash objects that have the keys `:word` and `:coordinates`.
        # @param width [Integer] the width of the "canvas" on which the words appear.
        # @param height [Integer] the height of the "canvas" on which the words appear.
        #
        # @return [String] a JSON encoded string.
        def self.to_json(words:, width: nil, height: nil)
          new(words: words, width: width, height: height).to_json
        end

        def initialize(words:, width:, height:)
          @words = words
          @width = width
          @height = height
        end
        attr_reader :words, :width, :height

        # Output JSON flattened word coordinates
        #
        # @return [String] JSON serialization of flattened word coordinates
        def to_json
          coordinates = {}
          words.each do |word|
            word_chars = word[:word]
            word_coords = word[:coordinates]
            if coordinates[word_chars]
              coordinates[word_chars] << word_coords
            else
              coordinates[word_chars] = [word_coords]
            end
          end
          payload = { width: width, height: height, coords: coordinates }
          JSON.generate(payload)
        end
      end
    end
  end
end
