# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Processes::PreProcess do
  let(:repository) { double(SpaceStone::Derivatives::Repository, local_for: false, remote_for: false) }
  let(:derivative) { double(SpaceStone::Derivatives::Types::BaseType, generate_for: false) }
  let(:instance) { described_class.new(repository: repository, derivative: derivative) }

  let(:handle) { :handle }

  describe "#call" do
    context 'when local exists in repository' do
      it "returns a handle" do
        expect(repository).to receive(:local_for).with(derivative: derivative).and_return(handle)
        expect(instance.call).to eq(handle)
        expect(repository).not_to have_received(:remote_for)
        expect(derivative).not_to have_received(:generate_for)
      end
    end
    context 'when local does not exist in repository' do
      context 'when remote exists for repository' do
        it "returns a handle" do
          expect(repository).to receive(:remote_for).with(derivative: derivative).and_return(handle)
          expect(instance.call).to eq(handle)
          expect(repository).to have_received(:local_for)
          expect(derivative).not_to have_received(:generate_for)
        end
      end

      context 'when remote does not exist for repository' do
        it "returns a handle" do
          expect(derivative).to receive(:generate_for).with(repository: repository).and_return(handle)
          expect(instance.call).to eq(handle)
          expect(repository).to have_received(:remote_for)
          expect(repository).to have_received(:local_for)
        end
      end

      context 'when nothing returns a handle' do
        it "raises a Exceptions::FailureToLocateDerivativeError" do
          expect { instance.call }.to raise_exception(SpaceStone::Derivatives::Exceptions::FailureToLocateDerivativeError)

          expect(derivative).to have_received(:generate_for)
          expect(repository).to have_received(:remote_for)
          expect(repository).to have_received(:local_for)
        end
      end
    end
  end
end
