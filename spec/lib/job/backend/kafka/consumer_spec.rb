# frozen_string_literal: true

RSpec.describe Atlas::Job::Backend::Kafka::Consumer, type: :job_backend do
  let(:consumer) { double(:consumer) }

  describe '.new' do
    subject { described_class.new(consumer) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#listen' do
    subject { described_class.new(consumer).listen(topic) }
    let(:topic) { 'foo' }

    it 'delegates to consumer' do
      expect(consumer).to receive(:subscribe).with(topic)
      subject
    end
  end

  describe '#mark_message_as_processed' do
    subject { described_class.new(consumer).mark_message_as_processed(message) }
    let(:message) { build(:job_message) }

    it 'delegates to consumer' do
      expect(consumer).to receive(:mark_message_as_processed).with(message.vendor_message)
      subject
    end
  end

  describe '#consume' do
    let(:instance) { described_class.new(consumer) }

    it 'start listening kafka messages' do
      expect(consumer).to receive(:each_message)
      instance.consume
    end

    context 'when a message is received' do
      let(:kafka_message_value) { { payload: {}, retries: 0, timestamp: 0 }.to_json }
      let(:kafka_message) { double(:kafka_message, value: kafka_message_value, topic: 'foo') }

      before do
        allow(consumer).to receive(:each_message).and_yield(kafka_message)
      end

      it 'calls the processor callback' do
        expect { |b| instance.consume(&b) }.to yield_control
      end

      context 'when kafka message is invalid' do
        let(:kafka_message_value) { 'not a valid json' }

        it "won't call the processor callback" do
          expect { |b| instance.consume(&b) }.to_not yield_control
        end
      end

      context 'when kafka message does not contain required fields' do
        let(:kafka_message_value) { { foo: :bar }.to_json }

        it "won't call the processor callback" do
          expect { |b| instance.consume(&b) }.to_not yield_control
        end
      end
    end
  end
end
