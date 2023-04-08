# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Types do
  describe '.for' do
    let(:manifest) { Fixtures.pre_processing_manifest(mime_type: mime_type) }
    subject { described_class.for(manifest: manifest) }

    context 'with a bad mime type' do
      let(:mime_type) { "really/bad" }

      it "raises a Exceptions::UnknownMimeTypeError" do
        expect { subject }.to raise_exception(SpaceStone::Derivatives::Exceptions::UnknownMimeTypeError)
      end
    end

    context 'without a mime type' do
      let(:mime_type) { nil }

      it "raises a Exceptions::ManifestMissingMimeTypeError" do
        expect { subject }.to raise_exception(SpaceStone::Derivatives::Exceptions::ManifestMissingMimeTypeError)
      end
    end

    context 'with a valid mime type' do
      let(:mime_type) { 'application/pdf' }
      it 'delegates to the configuration' do
        expect(SpaceStone::Derivatives.config).to receive(:derivatives_for).with(mime_type: kind_of(MIME::Type)).and_call_original

        expect(subject).to be_a(Array)
        expect(subject).not_to be_empty
      end
    end
  end
end
