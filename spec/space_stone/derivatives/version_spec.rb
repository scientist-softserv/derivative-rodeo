# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives do
  describe "VERSION" do
    it "exists" do
      expect(described_class::VERSION).to be_a(String)
    end
  end
end
