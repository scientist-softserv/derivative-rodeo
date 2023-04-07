# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Type::FitsType do
  let(:manifest) { Fixtures.pre_processing_manifest(mime_type: nil) }
  let(:environment) { Fixtures.pre_processing_environment(manifest: manifest) }
  subject(:instance) { described_class.new(environment: environment) }

  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to eq([:original]) }
  end

  describe "#generate" do
    # See https://github.com/samvera/hydra-works/blob/c9b9dd0cf11de671920ba0a7161db68ccf9b7f6d/spec/hydra/works/services/characterization_service_spec.rb
    # for this utility.
    let(:fits_response) { IO.read(Fixtures.path_for("ocr_color.tiff.fits.xml")) }

    before do
      expect(Hydra::FileCharacterization).to(
        receive(:characterize)
          .with(String, File.basename(manifest.original_filename), :fits)
          .and_return(fits_response)
      )
      # Need to ensure that this is here!
      environment.remote_pull!(derivative: :original)
    end

    it "runs fits against the original file" do
      expect { instance.generate }.to change { environment.local_exists?(derivative: :fits) }.from(false).to(true)
    end

    it "assigns the mime_type to the environment" do
      expect { instance.generate }.to change(environment, :mime_type).from(nil).to("image/tiff")
    end
  end
end
