# frozen_string_literal: true

RSpec.describe Derivative::Rodeo::Utilities::ImageIdentify do
  describe '.technical_metadata_for' do
    subject(:result) { described_class.technical_metadata_for(path: path) }
    context 'a gray-scale TIFF image' do
      let(:path) { Fixtures.path_for('ocr_gray.tiff') }
      it 'extracts metadata' do
        expect(result.color).to eq 'gray'
        expect(result.width).to eq 418
        expect(result.height).to eq 1046
        expect(result.bits_per_component).to eq 8
        expect(result.num_components).to eq 1
      end
    end

    context 'a monochrome TIFF image' do
      let(:path) { Fixtures.path_for('ocr_mono.tiff') }
      it 'extracts metadata' do
        expect(result.color).to eq 'monochrome'
        expect(result.width).to eq 1261
        expect(result.height).to eq 1744
        expect(result.bits_per_component).to eq 1
        expect(result.num_components).to eq 1
      end
    end

    context 'for a color TIFF image' do
      let(:path) { Fixtures.path_for('4.1.07.tiff') }

      it 'extracts metadata' do
        expect(result.color).to eq 'color'
        expect(result.width).to eq 256
        expect(result.height).to eq 256
        expect(result.bits_per_component).to eq 8
        # e.g. is 3, but would be four if sample image had an alpha channel
        expect(result.num_components).to eq 3
      end
    end

    context 'for a PDF' do
      let(:path) { Fixtures.path_for('minimal-1-page.pdf') }
      it "detects mime type of pdf" do
        expect(result.content_type).to eq 'application/pdf'
      end
    end
  end
end
