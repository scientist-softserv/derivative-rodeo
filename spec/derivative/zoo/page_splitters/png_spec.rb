# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Derivative::Zoo::PageSplitters::Png do
  let(:path) { __FILE__ }
  let(:pdf_pages_summary) { double(Derivative::Zoo::PdfPagesSummary) }

  let(:splitter) { described_class.new(path, pdf_pages_summary: pdf_pages_summary) }

  describe '.compression' do
    subject { described_class.compression }
    it { is_expected.to be_nil }
  end

  describe '.compression?' do
    subject { described_class.compression? }
    it { is_expected.to be_falsey }
  end

  describe '.image_extension' do
    subject { described_class.image_extension }
    it { is_expected.to eq('png') }
  end

  describe '#gsdevice' do
    DEFAULT_SUMMARY_ATTRIBUTES = {
      color_description: 'rgb',
      bits_per_channel: 0
    }.freeze

    [
      [{ color_description: 'gray', bits_per_channel: 2 }, 'pnggray'],
      [{ color_description: 'gray', bits_per_channel: 1 }, 'pngmonod'],
      [{ color_description: 'rgb', bits_per_channel: 1 }, 'png16m']
    ].each do |attributes, expected_value|
      context 'with #{attributes.inspect}' do
        it "is expected to be #{expected_value.inspect}" do
          summary = Derivative::Zoo::PdfPagesSummary.new(**DEFAULT_SUMMARY_ATTRIBUTES.merge(attributes))
          expect(described_class.new(__FILE__, pdf_pages_summary: summary).gsdevice).to eq(expected_value)
        end
      end
    end
  end
end
