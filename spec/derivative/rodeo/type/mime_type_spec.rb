# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Type::MimeType do
  let(:manifest) { Fixtures.manifest(mime_type: nil) }
  let(:arena) { Fixtures.arena(manifest: manifest) }
  subject(:instance) { described_class.new(arena: arena) }

  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:original]) }
  end

  describe "#generate" do
    before do
      allow(Derivative::Rodeo).to receive(:invoke_with)
      # Need to ensure that this is here!
      arena.remote_pull!(derivative: :original)
    end

    it "assigns the mime_type to the arena" do
      expect { instance.generate }.to change(arena, :mime_type).from(nil).to("image/tiff")
    end

    it "starts processing for the given mime type" do
      expect(Derivative::Rodeo).to receive(:invoke_with).with(json: kind_of(String))
      instance.generate
    end
  end
end
