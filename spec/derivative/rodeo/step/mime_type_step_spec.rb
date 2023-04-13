# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Step::MimeTypeStep do
  let(:manifest) { Fixtures.manifest(mime_type: nil) }
  let(:arena) { Fixtures.arena(manifest: manifest) }
  subject(:instance) { described_class.new(arena: arena) }

  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:original]) }
  end

  describe '.coerce_to_mime_type' do
    subject { described_class.coerce_to_mime_type(mime_type) }

    context 'with a bad mime step' do
      let(:mime_type) { "really/bad" }

      it { within_block_is_expected.to raise_exception(Derivative::Rodeo::Exceptions::UnknownMimeTypeError) }
    end

    context 'without a mime step' do
      let(:mime_type) { nil }

      it { within_block_is_expected.to raise_exception(Derivative::Rodeo::Exceptions::UnknownMimeTypeError) }
    end

    context 'with a valid string mime step' do
      let(:mime_type) { 'application/pdf' }
      it 'delegates to the configuration' do
        expect(subject.to_s).to eq(mime_type)
      end
    end

    context 'with a MIME::Type object' do
      let(:mime_type) { MIME::Types['application/pdf'].first }

      it 'uses that for determining the derivatives' do
        expect(subject.object_id).to eq(mime_type.object_id)
      end
    end
  end

  describe ".demand" do
    subject { described_class.demand!(manifest: manifest, storage: nil) }
    let(:manifest) { double(Derivative::Rodeo::Manifest, mime_type: mime_type) }

    context 'when the manifest has no mime_type' do
      let(:mime_type) { nil }
      it { within_block_is_expected.to raise_exception(Derivative::Rodeo::Exceptions::ManifestMissingMimeTypeError) }
    end

    context 'when the manifest has a valid mime_type' do
      let(:mime_type) { 'application/pdf' }
      it { is_expected.to be_a(MIME::Type) }
    end
  end

  describe ".next_steps_for" do
    around do |spec|
      previous_steps_by_media_type = described_class.steps_by_media_type
      previous_steps_by_sub_type = described_class.steps_by_sub_type
      previous_steps_by_mime_type = described_class.steps_by_mime_type
      described_class.steps_by_media_type = { image: [:a], application: [:d] }
      described_class.steps_by_sub_type = { "png" => [:b] }
      described_class.steps_by_mime_type = { "image/png" => [:c] }
      spec.run
      described_class.steps_by_media_type = previous_steps_by_media_type
      described_class.steps_by_sub_type = previous_steps_by_sub_type
      described_class.steps_by_mime_type = previous_steps_by_mime_type
    end

    it 'checks by media, mime, and sub step' do
      expect(described_class.next_steps_for(mime_type: 'image/png')).to match_array([:a, :b, :c])
      expect(described_class.next_steps_for(mime_type: 'image/tiff')).to match_array([:a])
      expect(described_class.next_steps_for(mime_type: 'application/pdf')).to match_array([:d])
    end
  end

  describe "#generate" do
    before do
      allow(Derivative::Rodeo).to receive(:process_derivative)
      # Need to ensure that this is here!
      arena.remote_pull!(derivative: :original)
    end

    it "assigns the mime_type to the arena" do
      expect { instance.generate }.to change(arena, :mime_type).from(nil).to("image/tiff")
    end

    it "starts processing for the given mime step" do
      expect(Derivative::Rodeo).to receive(:process_derivative).with(json: kind_of(String))
      instance.generate
    end
  end
end
