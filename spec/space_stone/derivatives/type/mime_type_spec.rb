# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Type::MimeType do
  let(:manifest) { Fixtures.pre_processing_manifest(mime_type: nil) }
  let(:environment) { Fixtures.pre_processing_environment(manifest: manifest) }
  subject(:instance) { described_class.new(environment: environment) }

  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:original]) }
  end

  describe "#generate" do
    before do
      allow(SpaceStone::Derivatives::Environment).to receive(:start_processing_for_mime_type!)
      # Need to ensure that this is here!
      environment.remote_pull!(derivative: :original)
    end

    it "assigns the mime_type to the environment" do
      expect { instance.generate }.to change(environment, :mime_type).from(nil).to("image/tiff")
    end

    it "starts processing for the given mime type" do
      instance.generate
      expect(SpaceStone::Derivatives::Environment).to have_received(:start_processing_for_mime_type!).with(environment: environment)
    end
  end
end
