# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Utilities::ImageJp2 do
  describe '.technical_metadata_for' do
    subject(:result) { described_class.technical_metadata_for(path: path) }

    context 'with a grayscale image' do
      let(:path) { Fixtures.path_for('ocr_gray.jp2') }

      it 'extracts the metadata' do
        expect(result[:color]).to eq 'gray'
        expect(result[:content_type]).to eq 'image/jp2'
        expect(result[:width]).to eq 418
        expect(result[:height]).to eq 1046
        expect(result[:bits_per_component]).to eq 8
        expect(result[:num_components]).to eq 1
      end
    end

    context 'with color image' do
      let(:path) { Fixtures.path_for('4.1.07.jp2') }

      it "gets metadata for color image" do
        expect(result[:color]).to eq 'color'
        expect(result[:width]).to eq 256
        expect(result[:content_type]).to eq 'image/jp2'
        expect(result[:height]).to eq 256
        expect(result[:bits_per_component]).to eq 8
        # e.g. is 3, but would be four if sample image had an alpha channel
        expect(result[:num_components]).to eq 3
      end
    end
  end
end
