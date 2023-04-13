# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Configuration do
  let(:config) { described_class.new }
  describe 'derivatives_for_pre_process=' do
    it 'coerces the given derivatives and assigns them' do
      expect do
        config.derivatives_for_pre_process = "original"
      end.to change(config, :derivatives_for_pre_process).from([:original, :mime_type]).to([:original])
    end
  end
end
