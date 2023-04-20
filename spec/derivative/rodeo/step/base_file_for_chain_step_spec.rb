# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Step::BaseFileForChainStep do
  describe '.prerequisites' do
    subject { described_class.prerequisites }
    it { is_expected.to be_empty }
  end

  let(:arena) { Fixtures.arena }
  subject(:instance) { described_class.new(arena: arena) }

  describe '#generate' do
    before { allow(arena).to receive(:remote_fetch!).with(derivative: :base_file_for_chain).and_call_original }

    context 'when file exists locally' do
      it 'will use the local and not pull from the remote' do
        allow(arena).to receive(:local_exists?).with(derivative: :base_file_for_chain).and_return(true)
        allow(arena).to receive(:local_path).with(derivative: :base_file_for_chain).and_return(__FILE__)
        expect(instance.generate).to be_present
      end
    end

    context 'when file does not exist locally' do
      it 'will pull from the remote' do
        instance.generate
        expect(arena).to have_received(:remote_fetch!)
      end
    end
  end
end
