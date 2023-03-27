# frozen_string_literal: true

RSpec.describe SpaceStone::PdfSplitter::Strategies::Base do
  subject { described_class.new(__FILE__, pdf_pages_summary: pdf_pages_summary) }
  let(:pdf_pages_summary) { double(SpaceStone::PdfSplitter::PdfPagesSummary) }

  # Becasue the described class is an abstract class, we want to verify its public interface.
  it { is_expected.to be_a(Enumerable) }
end
