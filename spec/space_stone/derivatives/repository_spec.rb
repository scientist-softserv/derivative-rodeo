# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpaceStone::Derivatives::Repository do
  let(:repository) { described_class.new(manifest: manifest, local_storage: :file_system, remote_storage: :file_system) }
  let(:manifest) { SpaceStone::Derivatives::Manifest.new(parent_identifier: "123", original_filename: "abc", derivatives: []) }

  describe "#local_for"
  describe "#demand_local_for!"
  describe "#remote_for"
end
