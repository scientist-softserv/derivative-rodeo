# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Types do
  describe '.for' do
    let(:manifest) { Fixtures.manifest(mime_type: mime_type) }
    subject { described_class.for(manifest: manifest) }

    context 'with a bad mime type' do
      let(:mime_type) { "really/bad" }

      it { within_block_is_expected.to raise_exception(Derivative::Rodeo::Exceptions::UnknownMimeTypeError) }
    end

    context 'without a mime type' do
      let(:mime_type) { nil }

      it { within_block_is_expected.to raise_exception(Derivative::Rodeo::Exceptions::ManifestMissingMimeTypeError) }
    end

    context 'with a valid mime type' do
      let(:mime_type) { 'application/pdf' }
      it 'delegates to the configuration' do
        expect(Derivative::Rodeo.config).to receive(:derivatives_for).with(mime_type: kind_of(MIME::Type)).and_call_original

        expect(subject).to be_a(Array)
        expect(subject).not_to be_empty
      end
    end

    context 'with a MIME::Type object' do
      let(:mime_type) { MIME::Types['application/pdf'].first }

      it 'uses that for determining the derivatives' do
        expect(Derivative::Rodeo.config).to receive(:derivatives_for).with(mime_type: mime_type).and_call_original

        expect(subject).to be_a(Array)
        expect(subject).not_to be_empty
      end
    end
  end
end
