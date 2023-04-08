# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Derivative::Zoo do
  describe "VERSION" do
    it "exists" do
      expect(described_class::VERSION).to be_a(String)
    end
  end
end
