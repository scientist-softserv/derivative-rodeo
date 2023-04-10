# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Message do
  let(:derivative) { :hocr }
  let(:arena) { Fixtures.pre_processing_arena }
  let(:queue) { Derivative::Rodeo::QueueAdapters.for(adapter: :inline) }
  describe '.to_json' do
    subject { described_class.to_json(derivative: derivative, arena: arena, queue: queue) }
    it { is_expected.to be_a String }
  end
end
