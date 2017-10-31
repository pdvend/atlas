# frozen_string_literal: true

RSpec.describe Atlas::Service::Telemetry::Adapter::KafkaAdapter, type: :adapter do
  let(:kafka) { class_double('Kafka') }
  let(:producer) { double('Kafka.producer') }
  let(:topic) { 'foobar' }

  before do
    allow(kafka).to receive(:producer).and_return(producer)
  end

  describe '#initialize' do
    subject { described_class.new(kafka, topic) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#log' do
    subject { described_class.new(kafka, topic).log(type, data) }
    let(:type) { 'type' }
    let(:data) { { fake: 'data' } }

    context 'with valid params' do
      let(:message) { { type: type, data: data } }

      before do
        allow(producer).to receive(:produce)
        allow(producer).to receive(:deliver_messages)
      end

      context 'send message to Kafka' do
        it 'produce' do
          expect(producer).to receive(:produce).with(message.to_json, topic: topic)
          subject
        end

        it 'send_messages' do
          expect(producer).to receive(:deliver_messages)
          subject
        end
      end
    end

    context 'with nil params' do
      before do
        allow(kafka).to receive(:producer).and_return(StandardError)
      end

      it_behaves_like 'a service with failure response'
    end
  end
end
