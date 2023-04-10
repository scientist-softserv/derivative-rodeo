# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Type do
  describe '.Type' do
    subject { Derivative::Rodeo.Type(type) }
    {
      hocr: Derivative::Rodeo::Type::HocrType,
      monochrome: Derivative::Rodeo::Type::MonochromeType
    }.each do |type, expected|
      context type.inspect.to_s do
        let(:type) { type }
        it { is_expected.to eq(expected) }
      end
    end

    context "for un-registered type" do
      subject { described_class.Type(:obviously_missing) }

      it { within_block_is_expected.to raise_exception(NameError) }
    end
  end
  describe "BaseType" do
    describe '.to_sym' do
      subject { described_class::BaseType.to_sym }
      it { is_expected.to eq(:base) }
    end

    let(:arena) { double(Derivative::Rodeo::Arena, dry_run?: false) }
    let(:instance) { described_class::BaseType.new(arena: arena) }
    subject { instance }

    it { is_expected.to delegate_method(:local_run_command!).to(:arena) }

    describe '#to_sym' do
      subject { instance.to_sym }
      it { is_expected.to eq(:base) }
    end

    describe "#generate" do
      it "raises a NotImplementedError" do
        expect { instance.generate }.to raise_error(NotImplementedError, "#{described_class::BaseType}#generate not implemented")
      end
    end
  end
end