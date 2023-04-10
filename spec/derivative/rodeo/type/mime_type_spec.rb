# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Type::MimeType do
  let(:manifest) { Fixtures.pre_processing_manifest(mime_type: nil) }
  let(:arena) { Fixtures.pre_processing_arena(manifest: manifest) }
  subject(:instance) { described_class.new(arena: arena) }

  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:original]) }
  end

  describe "#generate" do
    before do
      allow(Derivative::Rodeo::Arena).to receive(:for_mime_type_processing).and_call_original
      allow_any_instance_of(Derivative::Rodeo::Arena).to receive(:start_processing!)

      # Need to ensure that this is here!
      arena.remote_pull!(derivative: :original)
    end

    it "assigns the mime_type to the arena" do
      expect { instance.generate }.to change(arena, :mime_type).from(nil).to("image/tiff")
    end

    it "starts processing for the given mime type" do
      expect_any_instance_of(Derivative::Rodeo::Arena).to receive(:start_processing!)
      instance.generate
      expect(Derivative::Rodeo::Arena).to have_received(:for_mime_type_processing).with(arena: arena)
    end
  end
end
