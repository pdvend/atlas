# frozen_string_literal: true

RSpec.describe Atlas::Service::Telemetry::Emit, type: :service do
  describe '.new' do
    subject { described_class.new(adapter) }
    let(:adapter) { double(:adapter) }

    it { expect { subject }.to_not raise_error }
  end

  describe '#execute' do
    subject { described_class.new(adapter).execute(context, params) }
    let(:adapter) { double(:adapter) }
    let(:context) { build(:request_context) }

    before do
      allow(adapter).to receive(:log)
    end

    context 'with valid params' do
      let(:params) { { type: :fake, data: { fake: :data } } }

      it_behaves_like 'a service with valid params'
      it 'calls adapter#log' do
        expect(adapter).to receive(:log).with(:fake, fake: :data, **context.to_event.to_h)
        subject
      end
    end

    context 'with nil params' do
      let(:params) { nil }
      it_behaves_like 'a service with invalid params'
    end
  end
end
