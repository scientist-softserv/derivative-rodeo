# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::StorageAdapters::NullAdapter do
  let(:manifest) { Fixtures.manifest }
  subject(:instance) { described_class.new(manifest: manifest) }

  describe 'exists?' do
    subject { instance.exists?(derivative: :original) }
    it { is_expected.to be_falsey }
  end
end
