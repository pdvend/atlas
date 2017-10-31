# frozen_string_literal: true

RSpec.describe Atlas::Job::Backend::Kafka::Producer, type: :job_backend do
  let(:producer) { double(:producer) }

  describe '.new' do
    subject { described_class.new(producer) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#produce' do
    subject { described_class.new(producer).produce(topic, message) }

    let(:topic) { 'foo' }
    let(:message) { build(:job_message) }

    before do
      allow(producer).to receive(:produce)
      allow(producer).to receive(:deliver_messages)
    end

    it 'sends message via producer' do
      expect(producer).to receive(:produce).with(message.to_json, topic: topic)
      subject
    end

    it 'publish messages' do
      expect(producer).to receive(:deliver_messages)
      subject
    end

    context 'when message type is invalid' do
      let(:message) { nil }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when message content is invalid' do
      let(:message) { build(:job_message, timestamp: -1) }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#produce_batch' do
    subject { described_class.new(producer).produce_batch(topic, messages) }

    let(:topic) { 'foo' }
    let(:messages) { build_list(:job_message, 2) }

    before do
      allow(producer).to receive(:produce)
      allow(producer).to receive(:deliver_messages)
    end

    it 'sends messages via producer' do
      expect(producer).to receive(:produce).twice
      subject
    end

    it 'publish messages' do
      expect(producer).to receive(:deliver_messages)
      subject
    end

    context 'when there is a invalid message in type' do
      let(:messages) { [build(:job_message), nil] }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when there is a invalid message in contetn' do
      let(:messages) { [build(:job_message), build(:job_message, timestamp: -1)] }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
