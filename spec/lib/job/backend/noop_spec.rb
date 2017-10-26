# frozen_string_literal: true

RSpec.describe Atlas::Job::Backend::Noop, type: :job_backend do
  describe '.new' do
    subject { described_class.new }
    it { expect { subject }.to_not raise_error }
  end

  describe '#listen' do
    subject { described_class.new.listen('topic') }
    it { expect { subject }.to_not raise_error }
  end

  describe '#consume' do
    subject { described_class.new.consume }
    it { expect { subject }.to_not raise_error }
  end

  describe '#mark_message_as_processed' do
    subject { described_class.new.mark_message_as_processed(message) }
    let(:message) { double(:message) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#produce_batch' do
    subject { described_class.new.produce_batch('topic', []) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#produce' do
    subject { described_class.new.produce('topic', build_list(:job_message, 1)) }
    it { expect { subject }.to_not raise_error }
  end
end
