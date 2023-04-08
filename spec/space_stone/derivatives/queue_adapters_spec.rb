# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::QueueAdapters do
  describe '.for' do
    subject { described_class.for(adapter: adapter) }

    context 'with :inline' do
      let(:adapter) { :inline }
      it { is_expected.to be_a described_class::Base }
    end

    context 'with { name: :inline }' do
      let(:adapter) { { name: :inline } }
      it { is_expected.to be_a described_class::Base }
    end

    context 'with an adapter' do
      let(:adapter) { described_class::InlineAdapter.new }
      it "returns the given adapter" do
        expect(subject.object_id).to eq(adapter.object_id)
      end
    end

    context 'with a named but not registered adapter' do
      let(:adapter) { :no_such_thing }

      it { within_block_is_expected.to raise_exception(NameError) }
    end
    context 'with an unexpected adapter format' do
      let(:adapter) { 123 }

      it { within_block_is_expected.to raise_exception(SpaceStone::Derivatives::Exceptions::UnexpectedQueueAdapterError) }
    end
  end
end
