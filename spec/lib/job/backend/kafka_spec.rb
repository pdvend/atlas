# frozen_string_literal: true

RSpec.describe Atlas::Job::Backend::Kafka, type: :job_backend do
  let(:kafka) { double(:kafka) }
  let(:group_id) { 'foo' }
  let(:consumer) { double(:consumer) }
  let(:producer) { double(:producer) }

  before do
    allow(kafka).to receive(:consumer).and_return(consumer)
    allow(kafka).to receive(:producer).and_return(producer)
    allow(described_class::Consumer).to receive(:new).and_return(consumer)
    allow(described_class::Producer).to receive(:new).and_return(producer)
  end

  describe '.new' do
    subject { described_class.new(kafka, group_id) }

    it { expect { subject }.to_not raise_error }

    it 'passes arguments to create consumer' do
      expect(described_class::Consumer).to receive(:new).with(consumer)
      subject
    end

    it 'passes arguments to create producer' do
      expect(described_class::Producer).to receive(:new).with(producer)
      subject
    end
  end

  describe '#listen' do
    subject { described_class.new(kafka, group_id).listen }

    it 'delegates to consumer' do
      expect(consumer).to receive(:listen)
      subject
    end
  end

  describe '#consume' do
    subject { described_class.new(kafka, group_id).consume }

    it 'delegates to consumer' do
      expect(consumer).to receive(:consume)
      subject
    end
  end

  describe '#mark_message_as_processed' do
    subject { described_class.new(kafka, group_id).mark_message_as_processed }

    it 'delegates to consumer' do
      expect(consumer).to receive(:mark_message_as_processed)
      subject
    end
  end

  describe '#produce_batch' do
    subject { described_class.new(kafka, group_id).produce_batch }

    it 'delegates to producer' do
      expect(producer).to receive(:produce_batch)
      subject
    end
  end

  describe '#produce' do
    subject { described_class.new(kafka, group_id).produce }

    it 'delegates to producer' do
      expect(producer).to receive(:produce)
      subject
    end
  end
end
