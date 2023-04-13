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
