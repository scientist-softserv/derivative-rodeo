# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Environment do
  describe 'configuration' do
    subject { described_class }
    it { is_expected.to respond_to :local_adapter_name }
    it { is_expected.to respond_to :local_adapter_name= }
    it { is_expected.to respond_to :remote_adapter_name }
    it { is_expected.to respond_to :remote_adapter_name= }
    it { is_expected.to respond_to :queue_adapter_name }
    it { is_expected.to respond_to :queue_adapter_name= }
  end

  let(:original) { SpaceStone::Derivatives::Manifest::Original.new(parent_identifier: "abc", original_filename: 'efg.png', derivatives: [:hocr]) }
  let(:original_environment) { described_class.for_original(manifest: original, local: :file_system, remote: :file_system, queue: :inline) }

  describe '.for_original' do
    subject { original_environment }

    it { is_expected.to be_a described_class }
    it { is_expected.to respond_to :manifest }
    it { is_expected.to respond_to :local }
    it { is_expected.to respond_to :remote }
    it { is_expected.to respond_to :queue }
    it { is_expected.to respond_to :chain }
    it { is_expected.to respond_to :logger }

    it { is_expected.to respond_to :local_exists? }
    it { is_expected.to respond_to :local_assign! }
    it { is_expected.to respond_to :local_path }
    it { is_expected.to respond_to :local_demand! }
    it { is_expected.to respond_to :remote_pull! }
  end

  describe '.for_derived' do
    let(:derived) { SpaceStone::Derivatives::Manifest::Derived.new(original: original, derived: :split_pdf, index: 0, derivatives: [:pdf_split]) }
    subject { described_class.for_derived(manifest: derived, environment: original_environment) }

    it { is_expected.to be_a described_class }
    it { is_expected.to respond_to :manifest }
    it { is_expected.to respond_to :local }
    it { is_expected.to respond_to :remote }
    it { is_expected.to respond_to :queue }
    it { is_expected.to respond_to :chain }
    it { is_expected.to respond_to :logger }
    it { is_expected.to respond_to :local_exists? }
    it { is_expected.to respond_to :local_assign! }
    it { is_expected.to respond_to :local_path }
    it { is_expected.to respond_to :local_demand! }
    it { is_expected.to respond_to :remote_pull! }
  end

  describe '.new' do
    it "is a private method (don't call it directly)" do
      expect(described_class.private_methods).to include(:new)
    end
  end
end
