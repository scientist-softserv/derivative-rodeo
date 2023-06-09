# frozen_string_literal: true

RSpec.describe Derivative::Rodeo::Utilities::PdfSplitter::Base do
  subject { described_class.new(__FILE__, pdf_pages_summary: pdf_pages_summary) }
  let(:pdf_pages_summary) { double(Derivative::Rodeo::PdfPagesSummary) }

  # Becasue the described class is an abstract class, we want to verify its public interface.
  it { is_expected.to be_a(Enumerable) }

  describe '.gsdevice' do
    subject { described_class.gsdevice }
    it { is_expected.to be_nil }
  end

  describe '#gsdevice' do
    it "expects that you will have set .gsdevice in the subclass" do
      expect { subject.gsdevice }.to raise_error(NotImplementedError)
    end
  end
end
