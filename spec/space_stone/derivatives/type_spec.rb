# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Type do
  describe '.Type' do
    subject { SpaceStone::Derivatives.Type(type) }
    {
      hocr: SpaceStone::Derivatives::Type::HocrType,
      monochrome: SpaceStone::Derivatives::Type::MonochromeType
    }.each do |type, expected|
      context type.inspect.to_s do
        let(:type) { type }
        it { is_expected.to eq(expected) }
      end
    end

    context "for un-registered type" do
      it "is expected to raise an error" do
        expect { described_class.Type(:obviously_missing) }.to raise_exception(NameError)
      end
    end
  end
  describe "BaseType" do
    describe '.to_sym' do
      subject { described_class::BaseType.to_sym }
      it { is_expected.to eq(:base) }
    end

    let(:environment) { double(SpaceStone::Derivatives::Environment) }
    let(:instance) { described_class::BaseType.new(environment: environment) }
    subject { instance }

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
