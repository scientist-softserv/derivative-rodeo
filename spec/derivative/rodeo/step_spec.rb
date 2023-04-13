# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Step do
  describe '.Step' do
    subject { Derivative::Rodeo.Step(step) }
    {
      hocr: Derivative::Rodeo::Step::HocrStep,
      monochrome: Derivative::Rodeo::Step::MonochromeStep
    }.each do |step, expected|
      context step.inspect.to_s do
        let(:step) { step }
        it { is_expected.to eq(expected) }
      end
    end

    context "for un-registered step" do
      subject { described_class.Step(:obviously_missing) }

      it { within_block_is_expected.to raise_exception(NameError) }
    end
  end
  describe "BaseStep" do
    describe '.to_sym' do
      subject { described_class::BaseStep.to_sym }
      it { is_expected.to eq(:base) }
    end

    let(:arena) { double(Derivative::Rodeo::Arena, dry_run?: false) }
    let(:instance) { described_class::BaseStep.new(arena: arena) }
    subject { instance }

    it { is_expected.to delegate_method(:local_run_command!).to(:arena) }

    describe '#to_sym' do
      subject { instance.to_sym }
      it { is_expected.to eq(:base) }
    end

    describe "#generate" do
      it "raises a NotImplementedError" do
        expect { instance.generate }.to raise_error(NotImplementedError, "#{described_class::BaseStep}#generate not implemented")
      end
    end
  end
end
