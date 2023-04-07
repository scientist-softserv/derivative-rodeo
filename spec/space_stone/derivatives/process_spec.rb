# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Process do
  let(:derivative) { double(SpaceStone::Derivatives::Types::BaseType, generate_for: false) }
  let(:environment) { double(SpaceStone::Derivatives::Environment, local_path: false, remote_pull: false, process_next_chain_link_after!: false, local_exists?: true) }
  subject(:instance) { described_class.new(derivative: derivative, environment: environment) }
  let(:handle) { :handle }

  it { is_expected.to delegate_method(:local_read).to(:environment) }
  it { is_expected.to delegate_method(:local_path).to(:environment) }
  it { is_expected.to delegate_method(:remote_pull).to(:environment) }
  it { is_expected.to delegate_method(:process_next_chain_link_after!).to(:environment) }
  it { is_expected.to delegate_method(:local_exists?).to(:environment) }
  it { is_expected.to delegate_method(:logger).to(:environment) }
  it { is_expected.to delegate_method(:generate_for).to(:derivative) }

  describe ".call" do
    subject { described_class.call(derivative: derivative, environment: environment) }

    context 'when local exists in environment' do
      it "returns a handle" do
        expect(environment).to receive(:local_path).with(derivative: derivative).and_return(handle)
        expect(subject).to eq(handle)
        expect(environment).not_to have_received(:remote_pull)
        expect(derivative).not_to have_received(:generate_for)
        expect(environment).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
      end
    end
    context 'when local does not exist in environment' do
      context 'when remote exists for environment' do
        it "returns a handle" do
          expect(environment).to receive(:remote_pull).with(derivative: derivative).and_return(handle)
          expect(subject).to eq(handle)
          expect(environment).to have_received(:local_path)
          expect(derivative).not_to have_received(:generate_for)
          expect(environment).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when remote does not exist for environment' do
        it "returns a handle" do
          expect(derivative).to receive(:generate_for).with(environment: environment).and_return(handle)
          expect(subject).to eq(handle)
          expect(environment).to have_received(:remote_pull)
          expect(environment).to have_received(:local_path)
          expect(environment).to have_received(:process_next_chain_link_after!).with(derivative: derivative)
        end
      end

      context 'when nothing returns a handle' do
        it "raises a Exceptions::FailureToLocateDerivativeError" do
          expect(environment).to receive(:local_exists?).with(derivative: derivative).at_least(1).times.and_return(false)
          expect { subject }.to raise_exception(SpaceStone::Derivatives::Exceptions::FailureToLocateDerivativeError)

          expect(derivative).to have_received(:generate_for)
          expect(environment).to have_received(:remote_pull)
          expect(environment).not_to have_received(:local_path)
          expect(environment).not_to have_received(:process_next_chain_link_after!)
        end
      end
    end
  end
end
