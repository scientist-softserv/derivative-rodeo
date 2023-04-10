# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::QueueAdapters::InlineAdapter do
  let(:processor) { double(Derivative::Rodeo::Process, call: true) }
  subject(:instance) { described_class.new(processor: processor) }

  it { is_expected.to be_a Derivative::Rodeo::QueueAdapters::Base }

  describe '#enqueue' do
    let(:arena) { double(Derivative::Rodeo::Arena) }
    it 'sends the processor a #call message with the given derivative and arena' do
      instance.enqueue(derivative: :hocr, arena: arena)
      expect(processor).to have_received(:call).with(derivative: :hocr, arena: arena)
    end
  end

  describe '#to_hash' do
    subject { instance.to_hash }
    it { is_expected.to eq({ name: :inline }) }
  end
end
