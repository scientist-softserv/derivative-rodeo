# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::TextExtractors::Tesseract do
  describe '.call' do
    let(:path) { Fixtures.path_for('ocr_mono.tiff') }

    it 'generates a file at the returned value' do
      derivative_path = described_class.call(path: path)

      expect(derivative_path).to end_with(".#{described_class.output_base}")
      expect(File.exist?(derivative_path)).to be_truthy
    end
  end
end
