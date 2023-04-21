# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Manifest::Derived do
  let(:original) { Fixtures.manifest(work_identifier: 'abc', file_set_filename: 'def.jpg', derivatives: []) }
  let(:derivatives) { [:ocr] }
  subject(:instance) { described_class.new(original: original, first_spawn_step_name: :split_pdf, index: 0, derivatives: derivatives) }

  it { is_expected.to respond_to :original }
  it { is_expected.to respond_to :to_hash }
  it { is_expected.to respond_to :identifier }
  it { is_expected.to respond_to :first_spawn_step_name }
  it { is_expected.to respond_to :index }
  it { is_expected.to respond_to :derivatives }
  it { is_expected.to respond_to :directory_slugs }

  describe '#derivatives' do
    it "symbolizes the provided values" do
      expect(instance.derivatives.all? { |d| d.is_a?(Symbol) }).to be_truthy
    end
  end

  describe '#to_hash keys' do
    subject { instance.to_hash.keys }
    it { is_expected.to eq([:name, :derivatives, :first_spawn_step_name, :index, :original]) }
  end

  describe '#<=>' do
    let(:same_first_spawn_step_name) { described_class.new(original: original, first_spawn_step_name: :split_pdf, index: 0, derivatives: derivatives) }
    let(:other_first_spawn_step_name) { described_class.new(original: original, first_spawn_step_name: :split_pdf, index: 1, derivatives: derivatives) }
    let(:other_original) { Fixtures.manifest(work_identifier: 'ghi', file_set_filename: 'def.jpg', derivatives: []) }
    let(:first_spawn_step_name_from_other_manifest) { described_class.new(original: other_original, first_spawn_step_name: :split_pdf, index: 0, derivatives: derivatives) }

    it "compares the work identifier and the original file name" do
      expect(instance == same_first_spawn_step_name).to be_truthy
      expect(instance.object_id == same_first_spawn_step_name.object_id).to be_falsey
      expect(instance == other_first_spawn_step_name).to be_falsey
      expect(instance.object_id == other_first_spawn_step_name.object_id).to be_falsey
      expect(instance == first_spawn_step_name_from_other_manifest).to be_falsey
      expect(instance.object_id == first_spawn_step_name_from_other_manifest.object_id).to be_falsey
    end
  end
end
