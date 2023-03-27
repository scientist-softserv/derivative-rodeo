# frozen_string_literal: true
require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::TextExtractors::WordCoordinates do
  let(:words) do
    [
      { word: "foo", coordinates: [1, 2, 3, 4] },
      { word: "bar", coordinates: [5, 6, 7, 8] },
      { word: "baz", coordinates: [9, 10, 11, 12] },
      { word: "foo", coordinates: [13, 14, 15, 16] }
    ]
  end
  let(:image_width) { 1_234 }
  let(:image_height) { 5_678 }

  describe '.to_json' do
    let(:json) { JSON.parse(described_class.to_json(words: words, width: image_width, height: image_height)) }
    it 'has the correct structure' do
      expect(json['height']).to eq image_height
      expect(json['width']).to eq image_width
      expect(json['coords'].length).to eq 3
      expect(json['coords']['foo']).not_to be_falsey
    end

    it 'combines coordinates for the same word' do
      expect(json['coords']['foo']).to eq [[1, 2, 3, 4], [13, 14, 15, 16]]
    end
  end
end
