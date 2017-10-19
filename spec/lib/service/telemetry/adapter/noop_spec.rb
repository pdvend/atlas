# frozen_string_literal: true

RSpec.describe Atlas::Service::Telemetry::Adapter::NoopAdapter, type: :adapter do
  describe '#initialize' do
    subject { described_class.new }
    it { expect { subject }.to_not raise_error }
  end

  describe '#log' do
    subject { described_class.new.log(type, data) }
    let(:type) { 'type' }
    let(:data) { { fake: 'data' } }

    it { expect { subject }.to_not raise_error }
    it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::NONE) }
  end
end
