# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Rodeo::Configuration do
  let(:config) { described_class.new }
  describe "#derivatives_by" do
    before do
      config.derivatives_by_media_type = { image: [:a], application: [:d] }
      config.derivatives_by_sub_type = { "png" => [:b] }
      config.derivatives_by_mime_type = { "image/png" => [:c] }
    end

    it 'checks by media, mime, and sub type' do
      expect(config.derivatives_for(mime_type: MIME::Types['image/png'].first)).to match_array([:a, :b, :c])
      expect(config.derivatives_for(mime_type: MIME::Types['image/tiff'].first)).to match_array([:a])
      expect(config.derivatives_for(mime_type: MIME::Types['application/pdf'].first)).to match_array([:d])
    end
  end

  describe 'derivatives_for_pre_process=' do
    it 'coerces the given derivatives and assigns them' do
      expect do
        config.derivatives_for_pre_process = "original"
      end.to change(config, :derivatives_for_pre_process).from([:original, :mime]).to([:original])
    end
  end
end
