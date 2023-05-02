# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Step::HocrToAltoXmlStep do
  let(:hocr_path) { Fixtures.path_for("ocr_mono_text_hocr.html") }
  let(:base_file_for_chain_path) { Fixtures.path_for("ocr_color.tiff") }
  let(:arena) { Fixtures.arena }

  subject(:instance) { described_class.new(arena: arena) }

  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to match_array([:base_file_for_chain, :hocr]) }
  end

  it { is_expected.to respond_to :hocr_path }
  it { is_expected.to respond_to :base_file_for_chain_path }

  describe '#generate' do
    it 'assigns an hocr_to_alto_xml derivative' do
      arena.local_assign!(derivative: :hocr, path: hocr_path)
      arena.local_assign!(derivative: :base_file_for_chain, path: base_file_for_chain_path)
      expect do
        instance.generate
      end.to change { arena.local_exists?(derivative: described_class.to_sym) }.from(false).to(true)

      # Adding a little test to ensure we have different content
      step_content = File.read(arena.local_path(derivative: described_class.to_sym))
      hocr_content = File.read(arena.local_path(derivative: :hocr))
      expect(step_content).not_to eq(hocr_content)
    end
  end
end
