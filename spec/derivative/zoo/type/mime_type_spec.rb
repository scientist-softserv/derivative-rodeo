# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo::Type::MimeType do
  let(:manifest) { Fixtures.pre_processing_manifest(mime_type: nil) }
  let(:environment) { Fixtures.pre_processing_environment(manifest: manifest) }
  subject(:instance) { described_class.new(environment: environment) }

  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:original]) }
  end

  describe "#generate" do
    before do
      allow(Derivative::Zoo::Environment).to receive(:for_mime_type_processing).and_call_original
      allow_any_instance_of(Derivative::Zoo::Environment).to receive(:start_processing!)

      # Need to ensure that this is here!
      environment.remote_pull!(derivative: :original)
    end

    it "assigns the mime_type to the environment" do
      expect { instance.generate }.to change(environment, :mime_type).from(nil).to("image/tiff")
    end

    it "starts processing for the given mime type" do
      expect_any_instance_of(Derivative::Zoo::Environment).to receive(:start_processing!)
      instance.generate
      expect(Derivative::Zoo::Environment).to have_received(:for_mime_type_processing).with(environment: environment)
    end
  end
end
