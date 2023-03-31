# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Processes::Base do
  let(:repository) { double(SpaceStone::Derivatives::Repository) }
  let(:derivative) { double(SpaceStone::Derivatives::Types::BaseType) }

  describe '.call' do
    it 'instantiates the process and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(repository: repository, derivative: derivative)
    end
  end

  describe 'instance' do
    subject(:instance) { described_class.new(repository: repository, derivative: derivative) }

    it { is_expected.to respond_to :repository }
    it { is_expected.to respond_to :derivative }
    it { is_expected.to respond_to :call }

    it "expects that descendant classes will implement #call's functionality" do
      expect { instance.call }.to raise_exception(NotImplementedError)
    end
  end
end
