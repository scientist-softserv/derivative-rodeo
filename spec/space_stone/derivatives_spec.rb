# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives do
  let(:manifest) { double(SpaceStone::Derivatives::Manifest) }
  context '.pre_process_derivatives_for' do
    it 'forward delegates to PreProcessor' do
      expect(SpaceStone::Derivatives::Processor).to receive(:call).with(manifest: manifest, message: :pre_process!)
      described_class.pre_process_derivatives_for(manifest: manifest)
    end
  end
end
