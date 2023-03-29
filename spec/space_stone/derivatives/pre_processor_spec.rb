# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::PreProcessor do
  let(:manifest) do
    SpaceStone::Derivatives::Manifest.new(parent_identifier: 1, original_filename: "hello", derivatives: [:hocr])
  end

  # TODO: This should be something
  let(:repository) { :repository }
  let(:pre_processor) { described_class.new(manifest: manifest) }

  describe '#chain' do
    subject { pre_processor.chain }

    it { is_expected.to be_a SpaceStone::Derivatives::Chain }
  end

  describe '#call' do
    let(:first_link) { double(SpaceStone::Derivatives::Types::BaseType, pre_process!: true) }
    let(:second_link) { double(SpaceStone::Derivatives::Types::BaseType, pre_process!: true) }
    let(:chain) { [first_link, second_link] }
    let(:pre_processor) { described_class.new(manifest: manifest, chain: chain) }

    it 'iterates through the chain links' do
      pre_processor.call
      expect(first_link).to have_received(:pre_process!).with(manifest: manifest, repository: repository)
      expect(second_link).to have_received(:pre_process!).with(manifest: manifest, repository: repository)
    end
  end
end
