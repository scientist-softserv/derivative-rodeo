# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::QueueAdapters::InlineAdapter do
  subject(:instance) { described_class.new }

  it { is_expected.to be_a Derivative::Rodeo::QueueAdapters::Base }

  describe '#enqueue' do
    let(:arena) { Fixtures.pre_processing_arena }
    it 'sends the rodeo an .invoke_with message with a contextual message' do
      expect(Derivative::Rodeo).to receive(:invoke_with).with(message: kind_of(String), config: arena.config)
      instance.enqueue(derivative: :hocr, arena: arena)
    end
  end

  describe '#to_hash' do
    subject { instance.to_hash }
    it { is_expected.to eq({ name: :inline }) }
  end
end
