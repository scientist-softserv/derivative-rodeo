# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo::PageSplitters::Jpg do
  let(:path) { __FILE__ }
  let(:pdf_pages_summary) { double(Derivative::Zoo::PdfPagesSummary) }
  let(:splitter) { described_class.new(path, pdf_pages_summary: pdf_pages_summary) }

  describe '.gsdevice' do
    subject { described_class.gsdevice }
    it { is_expected.to eq('jpeg') }
  end

  describe '#gsdevice' do
    subject { splitter.gsdevice }
    it { is_expected.to eq('jpeg') }
  end

  describe '#quality' do
    subject { splitter.quality }
    it { is_expected.to eq(described_class.quality) }
  end

  describe '#quality?' do
    subject { splitter.quality? }
    it { is_expected.to be_truthy }
  end

  describe '#image_extension' do
    subject { splitter.image_extension }
    it { is_expected.to eq('jpg') }
  end
end
