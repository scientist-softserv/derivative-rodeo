# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Types::MonochromeType do
  describe ".prerequisites" do
    subject { described_class.prerequisites }
    it { is_expected.to eq([]) }
  end

  describe "#create_derivative_for" do
    let(:repository) { double(SpaceStone::Derivatives::Repository) }
    subject { described_class.new.pre_process!(repository: repository) }

    before do
      allow(repository).to receive(:local_path_for).with(derivative: described_class.to_sym).and_return(existing_path)
    end

    context 'with existing :monochrome' do
      let(:existing_path) { "path/to/hocr" }
      it "returns the existing :monochrome" do
        expect(subject).to eq(existing_path)
      end
    end
  end
end
