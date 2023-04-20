# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Step::FitsStep do
  let(:manifest) { Fixtures.manifest(mime_type: nil) }
  let(:arena) { Fixtures.arena(manifest: manifest) }
  subject(:instance) { described_class.new(arena: arena) }

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
          .with(String, File.basename(manifest.file_set_filename), :fits)
          .and_return(fits_response)
      )
      # Need to ensure that this is here!
      arena.remote_fetch!(derivative: :original)
    end

    xit "runs fits against the original file" do
      expect { instance.generate }.to change { arena.local_exists?(derivative: :fits) }.from(false).to(true)
    end
  end
end
