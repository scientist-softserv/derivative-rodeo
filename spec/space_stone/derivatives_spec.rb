# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives do
  let(:manifest) { double(SpaceStone::Derivatives::Manifest::Original) }
  context '.start_processing!' do
    it 'forward delegates to Environment' do
      expect(SpaceStone::Derivatives::Environment).to receive(:start_processing!).with(manifest: manifest)
      described_class.start_processing!(manifest: manifest)
    end

    xit 'handles a manifest for a PDF'
    xit 'handles a manifest for a JPG'
    xit 'handles a manifest for a PNG'
    xit 'handles a manifest for a MOV'
    xit 'handles a manifest for a WAV'
  end
end
