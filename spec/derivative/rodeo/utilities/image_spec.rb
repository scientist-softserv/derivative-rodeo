# frozen_string_literal: true

require 'spec_helper'

describe Derivative::Rodeo::Utilities::Image do
  let(:fixtures) { File.join(Derivative::Rodeo::GEM_PATH, 'spec/fixtures/files') }

  # Image fixtures to test identification, metadata extraction for:
  let(:gray_jp2) { Fixtures.path_for('ocr_gray.jp2') }
  let(:color_jp2) { Fixtures.path_for('4.1.07.jp2') }
  let(:gray_tiff) { Fixtures.path_for('ocr_gray.tiff') }
  let(:mono_tiff) { Fixtures.path_for('ocr_mono.tiff') }
  let(:color_tiff) { Fixtures.path_for('4.1.07.tiff') }
  let(:pdf) { Fixtures.path_for('minimal-1-page.pdf') }

  describe '#technical_metadata' do
    subject { described_class.new(path).technical_metadata }

    context 'with a JP2' do
      let(:path) { gray_jp2 }
      it 'delegates technical metadata to the ImageJp2' do
        expect(Derivative::Rodeo::Utilities::ImageJp2).to receive(:technical_metadata_for).with(path: gray_jp2)
        subject
      end
    end

    context 'with a non-JP2' do
      let(:path) { gray_tiff }
      it 'delegates technical metadata to the ImageIdentify' do
        expect(Derivative::Rodeo::Utilities::ImageIdentify).to receive(:technical_metadata_for).with(path: gray_tiff)
        subject
      end
    end
  end

  describe "converts images" do
    it "makes a monochrome TIFF from JP2" do
      tool = described_class.new(gray_jp2)
      dest = File.join(Dir.mktmpdir, 'mono.tif')
      tool.convert(dest, true)
      expect(File.exist?(dest)).to be true
      expect(described_class.new(dest).metadata.color).to eq 'monochrome'
    end

    it "makes a gray TIFF from JP2" do
      tool = described_class.new(gray_jp2)
      dest = File.join(Dir.mktmpdir, 'gray.tif')
      tool.convert(dest, false)
      expect(File.exist?(dest)).to be true
      expect(described_class.new(dest).metadata.color).to eq 'gray'
    end

    it "makes a monochrome TIFF from grayscale TIFF" do
      tool = described_class.new(gray_tiff)
      dest = File.join(Dir.mktmpdir, 'mono.tif')
      tool.convert(dest, true)
      expect(File.exist?(dest)).to be true
      expect(described_class.new(dest).metadata.color).to eq 'monochrome'
    end

    # Not yet supported to use this tool to make JP2, for now the only
    #   component in IiifPrint doing that is
    #   IiifPrint::JP2DerivativeService
    it "raises error on JP2 destination" do
      expect { described_class.new(gray_tiff).convert('out.jp2') }.to \
        raise_error(RuntimeError)
    end
  end
end
