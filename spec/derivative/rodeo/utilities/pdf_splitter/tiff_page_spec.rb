# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Derivative::Rodeo::Utilities::PdfSplitter::TiffPage do
  let(:path) { __FILE__ }
  let(:pdf_pages_summary) { double(Derivative::Rodeo::PdfPagesSummary) }

  let(:splitter) { described_class.new(path, pdf_pages_summary: pdf_pages_summary) }

  describe '.compression' do
    subject { described_class.compression }
    it { is_expected.to eq('lzw') }
  end

  describe '.compression?' do
    subject { described_class.compression? }
    it { is_expected.to be_truthy }
  end

  describe '.image_extension' do
    subject { described_class.image_extension }
    it { is_expected.to eq('tiff') }
  end

  describe '#gsdevice' do
    DEFAULT_SUMMARY_ATTRIBUTES = {
      page_count: 10,
      color_description: 'rgb',
      bits_per_channel: 0,
      channels: 0
    }.freeze

    [
      [{ color_description: 'gray', bits_per_channel: 2 }, 'tiffgray'],
      [{ color_description: 'gray', bits_per_channel: 1 }, 'tiffg4'],
      [{ color_description: 'rgb', bits_per_channel: 1 }, 'tiff24nc'],
      [{ color_description: 'rgb', channels: 8, bits_per_channel: 6 }, 'tiff48nc'],
      [{ color_description: 'rgb', channels: 8, bits_per_channel: 5 }, 'tiff24nc'],
      [{ color_description: 'rgb', channels: 8, bits_per_channel: 3 }, 'tiff24nc']
    ].each do |attributes, expected_value|
      context 'with #{attributes.inspect}' do
        it "is expected to be #{expected_value.inspect}" do
          summary = Derivative::Rodeo::PdfPagesSummary.new(**DEFAULT_SUMMARY_ATTRIBUTES.merge(attributes))
          expect(described_class.new(__FILE__, pdf_pages_summary: summary).gsdevice).to eq(expected_value)
        end
      end
    end
  end
end
