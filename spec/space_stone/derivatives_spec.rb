# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives do
  let(:manifest) { double(SpaceStone::Derivatives::Manifest) }
  context '.pre_process_derivatives_for' do
    it 'forward delegates to PreProcessor' do
      expect(SpaceStone::Derivatives::PreProcessor).to receive(:call).with(manifest: manifest)
      described_class.pre_process_derivatives_for(manifest: manifest)
    end
  end
end
